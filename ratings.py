# ======================================================================
#
# NAME:     Isabelle May
# ASSIGN:   Final Project
# COURSE:   CPSC 321, Fall 2024
# DESC:     A Python program to manage and record transactions for items
#           and freelance work. This includes retrieving user data, listing
#           available items or jobs, and updating records after a sale.
#           The program ensures smooth integration with a database for
#           secure and accurate transaction logging.
#
# ======================================================================

def ratings(cursor, user_email):
    """
    Display rating options to the user. 
    The user can rate freelance work or items 
    and view their ratings.
    """
    while True:
        print("\n--- Rating Options ---")
        print("1. Rate Freelance Work")
        print("2. Rate an Item")
        print("3. View My Freelance Ratings")
        print("4. View My Item Ratings")
        print("5. View Ratings About Me (Freelance Work)")
        print("6. View Ratings About Me (Items)")
        print("7. Back to Main Menu")

        choice = input("Choose an option: ")

        if choice == "1":
            rate_freelance_work(cursor, user_email)
        elif choice == "2":
            rate_item(cursor, user_email)
        elif choice == "3":
            view_freelance_ratings(cursor, user_email)
        elif choice == "4":
            view_item_ratings(cursor, user_email)
        elif choice == "5":
            view_ratings_about_user_freelance(cursor, user_email)
        elif choice == "6":
            view_ratings_about_user_items(cursor, user_email)
        elif choice == "7":
            break
        else:
            print("Invalid option. Please try again.")

def rate_freelance_work(cursor, user_email):
    """
    Allow the user to rate a freelancer for work they've completed.
    """
    cursor.execute("""
        SELECT FT.job_id, FW.description, FT.worker_email
        FROM FreelanceTransactions FT
        JOIN FreelanceWork FW ON FT.job_id = FW.job_id
        WHERE FT.buyer_email = %s;
    """, (user_email,))
    transactions = cursor.fetchall()

    if not transactions:
        print("No freelance transactions to rate.")
        return

    print("\n--- Freelance Work Transactions ---")
    for i, (job_id, description, worker_email) in enumerate(transactions, start=1):
        print(f"{i}. {description} (Worker: {worker_email})")

    choice = int(input("Select a job to rate: ")) - 1
    if choice < 0 or choice >= len(transactions):
        print("Invalid choice.")
        return

    job_id, _, worker_email = transactions[choice]
    rating = float(input("Enter rating (0.00 - 5.00): "))
    review = input("Enter review (optional): ")

    cursor.execute("""
        INSERT INTO FreelanceWorkRatings (freelance_job_id, rater_email, rating_email, rating, review)
        VALUES (%s, %s, %s, %s, %s);
    """, (job_id, user_email, worker_email, rating, review))
    print("Rating submitted successfully!")

def rate_item(cursor, user_email):
    """
    Allow the user to rate a seller for an item they purchased.
    """
    cursor.execute("""
        SELECT IT.item_id, I.item_description, IT.seller_email
        FROM ItemTransactions IT
        JOIN ItemsForSale I ON IT.item_id = I.item_id
        WHERE IT.buyer_email = %s;
    """, (user_email,))
    transactions = cursor.fetchall()

    if not transactions:
        print("No item transactions to rate.")
        return

    print("\n--- Purchased Items ---")
    for i, (item_id, seller_email) in enumerate(transactions, start=1):
        print(f"{i}. Item ID: {item_id} (Seller: {seller_email})")

    choice = int(input("Select an item to rate: ")) - 1
    if choice < 0 or choice >= len(transactions):
        print("Invalid choice.")
        return

    item_id, seller_email = transactions[choice]
    rating = float(input("Enter rating (0.00 - 5.00): "))
    review = input("Enter review (optional): ")

    cursor.execute("""
        INSERT INTO ItemRatings (item_id, rater_email, rating_email, rating, review)
        VALUES (%s, %s, %s, %s, %s);
    """, (item_id, user_email, seller_email, rating, review))
    print("Rating submitted successfully!")

def view_freelance_ratings(cursor, user_email):
    """
    Display the user's freelance ratings.
    """
    cursor.execute("""
        SELECT FWR.rating, FWR.review, FWR.created_at
        FROM FreelanceWorkRatings FWR
        WHERE FWR.rater_email = %s;
    """, (user_email,))
    ratings = cursor.fetchall()

    if not ratings:
        print("No freelance ratings found.")
        return

    print("\n--- My Freelance Ratings ---")
    for rating, review, created_at in ratings:
        print(f"Rating: {rating}\nReview: {review}\nDate: {created_at}\n")

def view_item_ratings(cursor, user_email):
    """
    Display the user's item ratings.
    """
    cursor.execute("""
        SELECT IR.rating, IR.review, IR.created_at
        FROM ItemRatings IR
        WHERE IR.rater_email = %s;
    """, (user_email,))
    ratings = cursor.fetchall()

    if not ratings:
        print("No item ratings found.")
        return

    print("\n--- My Item Ratings ---")
    for rating, review, created_at in ratings:
        print(f"Rating: {rating}\nReview: {review}\nDate: {created_at}\n")

def view_ratings_about_user_freelance(cursor, user_email):
    """
    View ratings received by the user for their freelance work.
    """
    query = """
    SELECT rating, review, created_at, rater_email
    FROM FreelanceWorkRatings
    WHERE rating_email = %s
    ORDER BY created_at DESC;
    """
    cursor.execute(query, (user_email,))
    results = cursor.fetchall()

    if results:
        print("\n--- Ratings About You (Freelance Work) ---")
        for rating, review, created_at, rater_email in results:
            print(f"Rating: {rating}/5.0")
            print(f"Review: {review or 'No review'}")
            print(f"Given by: {rater_email} on {created_at}\n")
    else:
        print("\nNo ratings received for your freelance work yet.")

def view_ratings_about_user_items(cursor, user_email):
    """
    View ratings received by the user for items they sold.
    """
    query = """
    SELECT rating, review, created_at, rater_email
    FROM ItemRatings
    WHERE rating_email = %s
    ORDER BY created_at DESC;
    """
    cursor.execute(query, (user_email,))
    results = cursor.fetchall()

    if results:
        print("\n--- Ratings About You (Items) ---")
        for rating, review, created_at, rater_email in results:
            print(f"Rating: {rating}/5.0")
            print(f"Review: {review or 'No review'}")
            print(f"Given by: {rater_email} on {created_at}\n")
    else:
        print("\nNo ratings received for items you sold yet.")
