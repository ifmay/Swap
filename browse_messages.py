# ======================================================================
#
# NAME:     Isabelle May
# ASSIGN:   Final Project
# COURSE:   CPSC 321, Fall 2024
# DESC:     This module handles user interactions related to messaging within
#           the SWAP platform. It includes functionality for browsing and
#           responding to conversations, creating new messages, and checking
#           if users exist before sending messages. The module allows users
#           to view their conversation history, send responses, and manage
#           message-related tasks with other platform users.
#
# ======================================================================

def browse_messages(cursor, user_email):
    """
    Display message options for the user: viewing messages or creating a message.
    """
    while True:
        print("\n--- Message Options ---")
        print("1. View Messages")
        print("2. Create a Message")
        print("3. Back to Main Menu")
        choice = input("Choose an option: ")

        if choice == "1":
            view_messages(cursor, user_email)
        elif choice == "2":
            create_message(cursor, user_email)
        elif choice == "3":
            return
        else:
            print("Invalid option. Please try again.")

def view_messages(cursor, user_email):
    """
    View all conversations the user has had and allow them to view and respond to specific conversations.
    """
    # Query for unique emails the user has messaged or received messages from
    cursor.execute("""
        SELECT DISTINCT 
            CASE
                WHEN sender_email = %s THEN recipient_email
                ELSE sender_email
            END AS other_email
        FROM Messages
        WHERE sender_email = %s OR recipient_email = %s;
    """, (user_email, user_email, user_email))
    conversations = cursor.fetchall()

    if not conversations:
        print("\nNo messages found.")
        return

    # Display the list of emails
    print("\n--- Your Conversations ---")
    email_list = [row[0] for row in conversations]
    for i, email in enumerate(email_list, start=1):
        print(f"{i}. {email}")

    # Prompt the user to pick a conversation
    try:
        choice = int(input("\nEnter the number of the person you want to view messages with (or 0 to go back): "))
        if choice == 0:
            return
        selected_email = email_list[choice - 1]
    except (ValueError, IndexError):
        print("Invalid choice. Please try again.")
        return

    # Display conversation history and allow response
    display_conversation_history(cursor, user_email, selected_email)
    respond_to_conversation(cursor, user_email, selected_email)
            
def display_conversation_history(cursor, user_email, selected_email):
    """
    Retrieve and display the conversation history between the current user and the selected email.
    """
    cursor.execute("""
        SELECT sender_email, message_content, date_sent
        FROM Messages
        WHERE (sender_email = %s AND recipient_email = %s)
           OR (sender_email = %s AND recipient_email = %s)
        ORDER BY date_sent ASC;
    """, (user_email, selected_email, selected_email, user_email))
    messages = cursor.fetchall()

    print(f"\n--- Conversation with {selected_email} ---")
    for sender, content, date in messages:
        sender_label = "You" if sender == user_email else sender
        print(f"[{date}] {sender_label}: {content}")

def respond_to_conversation(cursor, user_email, selected_email):
    """
    Allow the user to respond to a conversation.
    """
    while True:
        print("\n1. Respond to this conversation")
        print("2. Exit to message options")
        option = input("Choose an option: ")
        if option == "1":
            content = input("Enter your message: ")
            if content.strip():
                cursor.execute("""
                    INSERT INTO Messages (sender_email, recipient_email, message_content)
                    VALUES (%s, %s, %s);
                """, (user_email, selected_email, content))
                print("Message sent!")
                break
            else:
                print("Message cannot be empty.")
        elif option == "2":
            break
        else:
            print("Invalid option. Please try again.")

def create_message(cursor, user_email):
    """
    Prompt the user to send a message to a specific email.
    """
    recipient_email = input("\nEnter the email of the person you want to message: ").strip()
    if recipient_email == user_email:
        print("You cannot send a message to yourself.")
        return

    # Check if the recipient exists
    cursor.execute("SELECT email FROM Users WHERE email = %s;", (recipient_email,))
    if cursor.fetchone() is None:
        print("The specified email does not exist. Please try again.")
        return

    # Get the message content
    message_content = input("Enter your message: ").strip()
    if not message_content:
        print("Message cannot be empty.")
        return

    # Insert the message into the database
    cursor.execute("""
        INSERT INTO Messages (sender_email, recipient_email, message_content)
        VALUES (%s, %s, %s);
    """, (user_email, recipient_email, message_content))
    print("Message sent!")