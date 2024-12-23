# ======================================================================
#
# NAME:     Isabelle May
# ASSIGN:   Final Project
# COURSE:   CPSC 321, Fall 2024
# DESC:     This module allows users to browse items for sale in their city
#           based on various criteria such as category, date posted, and
#           seller rating. It provides options to view items filtered by
#           specific categories, sorted by posting date or by the highest
#           seller ratings. Users can also view detailed information about
#           the sellers associated with each item listing to facilitate
#           more informed purchasing decisions.
#
# ======================================================================

def browse_items(cursor, user_email):
    """
    Display browsing options for items in the user's city.
    """
    # Query to retrieve user information, including their city
    q = """
    SELECT f_name, l_name, email, city, rating
    FROM Users
    WHERE email = %s;
    """
    cursor.execute(q, (user_email,))
    user = cursor.fetchone()

    if user:
        user_city = user[3]  # Extract the user's city
        print("\n--- Items for Sale ---")
        
        while True:
            print("View Options:")
            print("1. Sort By Category")
            print("2. Sort By Date Posted")
            print("3. Sort By Highest Seller Rating")
            print("4. View User Information")
            print("5. Back to Main Menu")
            choice = input("Choose an option: ")

            if choice == "1":
                sort_by_category(cursor, user_email, user_city)
            elif choice == "2":
                sort_by_date_posted(cursor, user_email, user_city)
            elif choice == "3":
                sort_by_seller_rating(cursor, user_email, user_city)
            elif choice == "4":
                view_user_info(cursor, user_email,user_city)
            elif choice == "5":
                return
            else:
                print("Invalid option. Please try again.")
    else:
        print("Error: Unable to fetch profile information.")


def sort_by_category(cursor, user_email, user_city):
    """
    Displays items for sale filtered by a specified category and city, excluding the user's own items.
    """
    categories = [
        'Furniture', 'Textbooks', 'Electronics', 'Clothing', 'Toys',
        'Sports Equipment', 'Books', 'Home Appliances', 'Kitchenware', 'Art Supplies'
    ]

    print("\n--- Select a Category ---")
    for i, category in enumerate(categories, 1):
        print(f"{i}. {category}")

    try:
        choice = int(input("Enter the number corresponding to your desired category: "))
        if 1 <= choice <= len(categories):
            selected_category = categories[choice - 1]
            print(f"\n--- Items in Category: {selected_category} ---")

            query = """
            SELECT item_id, item_description, price, seller_email, created_at
            FROM ItemsForSale i
            JOIN Users u ON i.seller_email = u.email
            WHERE i.item_type = %s AND u.city = %s AND i.seller_email != %s AND i.availability_status = TRUE
            ORDER BY created_at DESC;
            """
            cursor.execute(query, (selected_category, user_city, user_email))
            items = cursor.fetchall()

            if items:
                for item in items:
                    print(f"Item ID: {item[0]}, Description: {item[1]}, Price: ${item[2]:.2f}, "
                          f"Seller: {item[3]}, Date Posted: {item[4]}")
            else:
                print(f"No items found in the category: {selected_category}")
        else:
            print("Invalid category selection. Please choose a number between 1 and 10.")
    except ValueError:
        print("Invalid input. Please enter a valid number corresponding to a category.")

def sort_by_date_posted(cursor, user_email, user_city):
    """
    Display items for sale sorted by the date they were posted in the user's city, excluding the user's own items.
    """
    query = """
    SELECT i.item_type, i.item_description, i.price, i.seller_email, i.created_at
    FROM ItemsForSale i
    JOIN Users u ON i.seller_email = u.email
    WHERE i.availability_status = TRUE AND u.city = %s AND i.seller_email != %s
    ORDER BY i.created_at DESC;
    """
    cursor.execute(query, (user_city, user_email))
    items = cursor.fetchall()

    print("\n--- Items Sorted By Date Posted ---")
    for item in items:
        print(f"Date Posted: {item[4]}, Category: {item[0]}, Description: {item[1]}, Price: ${item[2]:.2f}, Seller: {item[3]}")
    print()

def sort_by_seller_rating(cursor, user_email, user_city):
    """
    Display items for sale sorted by the highest seller rating in the user's city, excluding the user's own items.
    """
    query = """
    SELECT i.item_type, i.item_description, i.price, i.seller_email, u.rating
    FROM ItemsForSale i
    JOIN Users u ON i.seller_email = u.email
    WHERE i.availability_status = TRUE AND u.city = %s AND i.seller_email != %s
    ORDER BY u.rating DESC;
    """
    cursor.execute(query, (user_city, user_email))
    items = cursor.fetchall()

    print("\n--- Items Sorted By Highest Seller Rating ---")
    for item in items:
        print(f"Seller Rating: {item[4]:.2f}, Category: {item[0]}, Description: {item[1]}, Price: ${item[2]:.2f}, Seller: {item[3]}")
    print()

def view_user_info(cursor, user_email, user_city):
    """
    Display the profile information of a seller based on a selected item.

    Args:
        cursor: The database cursor object to execute queries.
    """
    # Query to fetch all active listings
    query = """
    SELECT i.item_type, i.item_description, i.price, i.seller_email, i.created_at
    FROM ItemsForSale i
    JOIN Users u ON i.seller_email = u.email
    WHERE i.availability_status = TRUE AND u.city = %s AND i.seller_email != %s
    ORDER BY i.created_at DESC;
    """
    cursor.execute(query, (user_city, user_email))
    items = cursor.fetchall()

    if items:
        print("\n--- Available Listings ---")
        for i, item in enumerate(items, 1):
            print(f"{i}. Item ID: {item[0]}, Description: {item[1]}, Price: ${item[2]:.2f}, Seller: {item[3]}")

        try:
            choice = int(input("\nSelect an item by number to view seller information: "))
            
            if 1 <= choice <= len(items):
                selected_item = items[choice - 1]
                seller_email = selected_item[3]

                # Query to fetch the seller's information
                user_info_query = """
                SELECT f_name, l_name, email, city, state, rating
                FROM Users
                WHERE email = %s;
                """
                cursor.execute(user_info_query, (seller_email,))
                user = cursor.fetchone()

                if user:
                    print("\n--- Seller Information ---")
                    print(f"Name: {user[0]} {user[1]}")
                    print(f"Email: {user[2]}")
                    print(f"City: {user[3]}, State: {user[4]}")
                    print(f"Seller Rating: {user[5]:.2f}")
                else:
                    print("Error: Unable to fetch seller information.")
            else:
                print("Invalid selection. Please choose a valid listing number.")
        except ValueError:
            print("Invalid input. Please enter a number corresponding to a listing.")
    else:
        print("No listings available at the moment.")