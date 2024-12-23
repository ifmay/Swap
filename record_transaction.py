# ======================================================================
#
# NAME:     Isabelle May
# ASSIGN:   Final Project
# COURSE:   CPSC 321, Fall 2024
# DESC:     A Python program to manage user profiles, including listing
#           and updating items for sale, creating freelance job postings,
#           and managing ratings. The program interacts with a database to
#           fetch, insert, update, and delete user-related data.
#
# ======================================================================

def record_transaction(cursor, user_email):
    """
    Record a sale for either an item or freelance work.
    """
    # Query to retrieve user information
    q = """
    SELECT f_name, l_name, email
    FROM Users
    WHERE email = %s;
    """
    cursor.execute(q, (user_email,))
    user = cursor.fetchone()

    if user:
        print("\n--- Record a Sale ---")

        while True:
            print("Choose a sale type:")
            print("1. Record Item Sale")
            print("2. Record Freelance Work Sale")
            print("3. Back to Main Menu")
            choice = input("Choose an option: ")

            if choice == "1":
                record_item_sale(cursor, user_email)
            elif choice == "2":
                record_freelance_work_sale(cursor, user_email)
            elif choice == "3":
                return
            else:
                print("Invalid option. Please try again.")
    else:
        print("Error: Unable to fetch profile information.")

def record_item_sale(cursor, user_email):
    """
    Record an item sale transaction after listing the user's items and looking up by ID.
    """
    try:
        # List items posted by the user
        cursor.execute(
            "SELECT item_id, item_description, price, availability_status FROM ItemsForSale WHERE seller_email = %s;",
            (user_email,),
        )
        items = cursor.fetchall()

        if not items:
            print("You have no items listed for sale.")
            return

        print("\nYour Items for Sale:")
        for item_id, description, price, availability in items:
            status = "Available" if availability else "Sold"
            print(f"ID: {item_id}, Description: '{description}', Price: ${price:.2f}, Status: {status}")

        # Prompt for item ID
        item_id = int(input("\nEnter the ID of the item to record its sale: "))
        cursor.execute(
            "SELECT item_description, price, availability_status FROM ItemsForSale WHERE item_id = %s AND seller_email = %s;",
            (item_id, user_email),
        )
        item = cursor.fetchone()

        if not item:
            print("Invalid item ID or you are not the seller.")
            return

        item_description, price, availability_status = item
        if not availability_status:
            print("This item has already been sold.")
            return

        # Get buyer and transaction details
        buyer_email = input("Enter the buyer's email: ")
        amount_paid = float(input(f"Enter the amount paid (default: ${price}): ") or price)

        # Record the transaction
        cursor.execute(
            """
            INSERT INTO ItemTransactions (item_id, buyer_email, seller_email, amount_paid)
            VALUES (%s, %s, %s, %s);
            """,
            (item_id, buyer_email, user_email, amount_paid),
        )

        # Update item availability
        cursor.execute(
            "UPDATE ItemsForSale SET availability_status = FALSE WHERE item_id = %s;",
            (item_id,),
        )
        print(f"\nTransaction recorded: '{item_description}' sold for ${amount_paid} to {buyer_email}.")

    except Exception as e:
        print(f"Error recording item sale: {e}")


def record_freelance_work_sale(cursor, user_email):
    """
    Record a freelance work sale transaction after listing the user's jobs and looking up by ID.
    """
    try:
        # List jobs posted by the user
        cursor.execute(
            "SELECT job_id, description, payment FROM FreelanceWork WHERE posted_by = %s;",
            (user_email,),
        )
        jobs = cursor.fetchall()

        if not jobs:
            print("You have no freelance jobs listed.")
            return

        print("\nYour Freelance Jobs:")
        for job_id, description, payment in jobs:
            print(f"ID: {job_id}, Description: '{description}', Payment: ${payment:.2f}/hour")

        # Prompt for job ID
        job_id = int(input("\nEnter the ID of the freelance job to record its sale: "))
        cursor.execute(
            "SELECT description, payment FROM FreelanceWork WHERE job_id = %s AND posted_by = %s;",
            (job_id, user_email),
        )
        job = cursor.fetchone()

        if not job:
            print("Invalid job ID or you are not the poster.")
            return

        description, payment = job

        # Get worker and transaction details
        worker_email = input("Enter the worker's email: ")
        amount_paid = float(input(f"Enter the amount paid (default: ${payment}): ") or payment)

        # Record the transaction
        cursor.execute(
            """
            INSERT INTO FreelanceTransaction (job_id, buyer_email, worker_email, amount_paid)
            VALUES (%s, %s, %s, %s);
            """,
            (job_id, user_email, worker_email, amount_paid),
        )
        print(f"\nTransaction recorded: '{description}' paid ${amount_paid} to {worker_email}.")

    except Exception as e:
        print(f"Error recording freelance work sale: {e}")
