# ======================================================================
#
# NAME:     Isabelle May
# ASSIGN:   Final Project
# COURSE:   CPSC 321, Fall 2024
# DESC:     A Python program to manage user profiles, including listing
#           and updating items for sale, creating freelance job postings,
#           and managing ratings. The program interacts with a database
#           to fetch, insert, update, and delete user-related data.
#
# ======================================================================

def profile(cursor, user_email):
    """Display user profile information and provide options for managing listings and job postings."""
    # Query to retrieve user information along with calculated seller rating
    q = """
    SELECT 
        u.f_name, u.l_name, u.email, u.city, u.state, u.university,
        ROUND(
            (u.rating + 
             CASE WHEN COUNT(ir.rating) > 0 THEN AVG(ir.rating) ELSE 5 END +
             CASE WHEN COUNT(fr.rating) > 0 THEN AVG(fr.rating) ELSE 5 END) / 3, 
            2
        ) AS calculated_rating
    FROM 
        Users u
    LEFT JOIN 
        ItemRatings ir ON ir.rating_email = u.email
    LEFT JOIN 
        FreelanceWorkRatings fr ON fr.rating_email = u.email
    WHERE 
        u.email = %s
    GROUP BY 
        u.f_name, u.l_name, u.email, u.city, u.state, u.university, u.rating;
    """
    cursor.execute(q, (user_email,))
    user = cursor.fetchone()

    if user:
        print("\n--- My Profile ---")
        print(f"Name: {user[0]} {user[1]}")
        print(f"Email: {user[2]}")
        print(f"Location: {user[3]}, {user[4]}")
        print(f"University: {user[5]}")
        print(f"Seller Rating: {user[6]:.2f}")

        while True:
            print("\nProfile Options:")
            print("1. View My Listings/Postings")
            print("2. Create a Listing/Job Posting")
            print("3. Delete a Listing/Job Posting")
            print("4. Update a Listing/Job Posting")
            print("5. Back to Main Menu")
            choice = input("Choose an option: ")

            if choice == "1":
                print("\n1. View My Item Listings")
                print("2. View My Job Postings")
                sub_choice = input("Choose an option: ")
                if sub_choice == "1":
                    view_listings(cursor, user_email)
                elif sub_choice == "2":
                    view_job_postings(cursor, user_email)
                else:
                    print("Invalid option. Returning to profile.")

            elif choice == "2":
                print("\n1. Create an Item Listing")
                print("2. Create a Job Posting")
                sub_choice = input("Choose an option: ")
                if sub_choice == "1":
                    create_listing(cursor, user_email)
                elif sub_choice == "2":
                    create_job_posting(cursor, user_email)
                else:
                    print("Invalid option. Returning to profile.")

            elif choice == "3":
                print("\n1. Delete an Item Listing")
                print("2. Delete a Job Posting")
                sub_choice = input("Choose an option: ")
                if sub_choice == "1":
                    delete_listing(cursor, user_email)
                elif sub_choice == "2":
                    delete_job_posting(cursor, user_email)
                else:
                    print("Invalid option. Returning to profile.")

            elif choice == "4":
                print("\n1. Update an Item Listing")
                print("2. Update a Job Posting")
                sub_choice = input("Choose an option: ")
                if sub_choice == "1":
                    update_listing(cursor, user_email)
                elif sub_choice == "2":
                    update_job_posting(cursor, user_email)
                else:
                    print("Invalid option. Returning to profile.")

            elif choice == "5":
                print("Returning to Main Menu...")
                break

            else:
                print("Invalid option. Please try again.")
    else:
        print("Error: Unable to fetch profile information.")

def view_listings(cursor, user_email):
    """View all items listed for sale by the user."""
    q = """
    SELECT item_id, item_type, item_description, price, availability_status
    FROM ItemsForSale
    WHERE seller_email = (SELECT email FROM Users WHERE email = %s);
    """
    cursor.execute(q, (user_email,))
    listings = cursor.fetchall()
    print("\n--- My Listings ---")
    if listings:
        for listing in listings:
            print(f"ID: {listing[0]}, Type: {listing[1]}, Description: {listing[2]}")
            print(f"Price: ${listing[3]:.2f}, Available: {'Yes' if listing[4] else 'No'}")
            print("-" * 40)
    else:
        print("No listings found.")

def view_job_postings(cursor, user_email):
    """View all job postings created by the user."""
    q = """
    SELECT job_id, skill_type, description, payment
    FROM FreelanceWork
    WHERE posted_by = (SELECT email FROM Users WHERE email = %s);
    """
    cursor.execute(q, (user_email,))
    jobs = cursor.fetchall()
    print("\n--- My Job Postings ---")
    if jobs:
        for job in jobs:
            print(f"ID: {job[0]}, Skill: {job[1]}")
            print(f"Description: {job[2]}")
            print(f"Payment: ${job[3]:.2f}/hour")
            print("-" * 40)
    else:
        print("No job postings found.")

def create_listing(cursor, user_email):
    """Create a new item listing for sale."""
    # Get the user_email from Users table
    q = "SELECT email FROM Users WHERE email = %s"
    cursor.execute(q, (user_email,))
    user = cursor.fetchone()

    if user:
        user_email = user[0]  # Set the user_email correctly
    else:
        print(f"No user found with email: {user_email}")
        return None

    # Get item details from the user
    item_type = input("Enter the item type (e.g., 'Furniture', 'Textbooks'): ")
    item_description = input("Enter a description of the item: ")
    price = float(input("Enter the price of the item: "))
    availability_status = input("Is the item available? (yes/no): ").strip().lower()
    availability_status = availability_status == 'yes'  # Convert to boolean

    # Ensure item type exists in the ItemTypes table
    item_type_check_q = "SELECT 1 FROM ItemTypes WHERE type_name = %s"
    cursor.execute(item_type_check_q, (item_type,))
    if cursor.fetchone() is None:
        print(f"Item type '{item_type}' not found in the database. Please add it first.")
        return None

    # Insert the item listing into the ItemsForSale table
    insert_q = """
    INSERT INTO ItemsForSale (seller_email, item_type, item_description, price, availability_status)
    VALUES (%s, %s, %s, %s, %s) RETURNING item_id;
    """
    cursor.execute(insert_q, (user_email, item_type, item_description, price, availability_status))
    item_id = cursor.fetchone()[0]
    cursor.connection.commit()

    print(f"Item listed successfully! Item ID: {item_id}")
    return item_id

def create_job_posting(cursor, user_email):
    """Create a new freelance job posting."""
    # Get the user_email from Users table
    q = "SELECT email FROM Users WHERE email = %s"
    cursor.execute(q, (user_email,))
    user = cursor.fetchone()

    if user:
        user_email = user[0]  # Set the user_email correctly
    else:
        print(f"No user found with email: {user_email}")
        return None

    # Get job posting details from the user
    skill_type = input("Enter the skill type for the job (e.g., 'Web Development', 'Marketing'): ")
    description = input("Enter a detailed description of the job: ")
    payment = float(input("Enter the payment amount per hour for the job: "))

    # Insert the job posting into the FreelanceWork table
    insert_q = """
    INSERT INTO FreelanceWork (skill_type, description, payment, posted_by)
    VALUES (%s, %s, %s, %s) RETURNING job_id;
    """
    cursor.execute(insert_q, (skill_type, description, payment, user_email))
    job_id = cursor.fetchone()[0]  # Get the job_id of the newly created job posting
    cursor.connection.commit()

    print(f"Job posting created successfully! Job ID: {job_id}")
    return job_id

def delete_listing(cursor, user_email):
    """Delete a specific item listing by its ID."""
    view_listings(cursor, user_email)
    item_id = input("Enter the ID of the listing to delete: ")

    # Query to delete the listing where the seller's email matches the user_email
    q = """
    DELETE FROM ItemsForSale
    WHERE item_id = %s AND seller_email = %s;
    """
    cursor.execute(q, (item_id, user_email))
    cursor.connection.commit()

    if cursor.rowcount > 0:
        print("Listing deleted successfully.")
    else:
        print("Failed to delete listing. Please check the ID.")

def delete_job_posting(cursor, user_email):
    """Delete a specific job posting by its ID."""
    view_job_postings(cursor, user_email)
    job_id = input("Enter the ID of the job posting to delete: ")

    # Query to delete the job posting where the posted_by email matches the user_email
    q = """
    DELETE FROM FreelanceWork
    WHERE job_id = %s AND posted_by = %s;
    """
    cursor.execute(q, (job_id, user_email))
    cursor.connection.commit()
    if cursor.rowcount > 0:
        print("Job posting deleted successfully.")
    else:
        print("Failed to delete job posting. Please check the ID.")

def update_listing(cursor, user_email):
    """Allow the user to update a listing."""
    # Retrieve the listings for the user
    q = """
    SELECT item_id, item_description, price
    FROM ItemsForSale
    WHERE seller_email = %s;
    """
    cursor.execute(q, (user_email,))
    listings = cursor.fetchall()

    if listings:
        print("\n--- My Listings ---")
        for i, listing in enumerate(listings, start=1):
            print(f"{i}. {listing[1]} - ${listing[2]:.2f} (ID: {listing[0]})")

        choice = int(input("\nChoose the listing number to update (0 to cancel): "))

        if choice > 0 and choice <= len(listings):
            listing = listings[choice - 1]
            new_description = input(f"Enter a new description for '{listing[1]}': ")
            new_price = float(input(f"Enter a new price for '{listing[1]}': $"))

            # Update the listing in the database
            q = """
            UPDATE ItemsForSale
            SET item_description = %s, price = %s
            WHERE item_id = %s;
            """
            cursor.execute(q, (new_description, new_price, listing[0]))
            print(f"Listing '{listing[1]}' has been updated.")
        else:
            print("Invalid selection. Returning to profile.")
    else:
        print("No listings found to update.")

def update_job_posting(cursor, user_email):
    """Allow the user to update a job posting."""
    # Retrieve the job postings for the user
    q = """
    SELECT job_id, description, rate
    FROM FreelanceWork
    WHERE creator_email = %s;
    """
    cursor.execute(q, (user_email,))
    job_postings = cursor.fetchall()

    if job_postings:
        print("\n--- My Job Postings ---")
        for i, job in enumerate(job_postings, start=1):
            print(f"{i}. {job[1]} - ${job[2]:.2f} per hour (ID: {job[0]})")

        choice = int(input("\nChoose the job posting number to update (0 to cancel): "))

        if choice > 0 and choice <= len(job_postings):
            job = job_postings[choice - 1]
            new_description = input(f"Enter a new description for '{job[1]}': ")
            new_rate = float(input(f"Enter a new hourly rate for '{job[1]}': $"))

            # Update the job posting in the database
            q = """
            UPDATE FreelanceWork
            SET description = %s, rate = %s
            WHERE job_id = %s;
            """
            cursor.execute(q, (new_description, new_rate, job[0]))
            print(f"Job posting '{job[1]}' has been updated.")
        else:
            print("Invalid selection. Returning to profile.")
    else:
        print("No job postings found to update.")
