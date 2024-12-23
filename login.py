# ======================================================================
#
# NAME:     Isabelle May
# ASSIGN:   Final Project
# COURSE:   CPSC 321, Fall 2024
# DESC:     This module provides functionality for user authentication
#           in the SWAP application. It includes methods for logging in
#           existing users and signing up new users, ensuring data
#           validation, secure storage, and integration with the database.
#
# ======================================================================

def log_in(cursor):
    """Log in the user by verifying email and password."""
    email = input("Enter your email: ")
    password = input("Enter your password: ")

    q = "SELECT f_name FROM Users WHERE email = %s AND password = %s"
    cursor.execute(q, (email, password))
    result = cursor.fetchone()
    
    if result:
        print(f"\nWelcome, {result[0]}!")
        return email  # Return the email of the logged-in user
    else:
        print("\nInvalid email or password. Please try again.")
        return None  # Return None if login fails
    
def sign_up(cursor):
    """Sign up a new user by inserting their details into the database."""
    email = input("Enter your email: ")
    if check_email_exists(cursor, email):
        print(f"An account with email address: '{email}' already exists.")
        return None  # Return None if the email already exists
    else:
        f_name = input("Enter your first name: ")
        l_name = input("Enter your last name: ")
        city = input("Enter your city: ")
        state = input("Enter your state (2-letter code): ")
        university = input("Enter your university (only if you are a student): ")
        password = input("Enter your password: ")  # could hide password input for security
        insert_sign_up_info(cursor, f_name, l_name, city, state, email, university, password)
        print(f"\nAccount for {f_name} {l_name} created successfully.")
        cursor.connection.commit()  # Commit the transaction
        return email  # Return the email of the newly signed-up user


# checks if an email already exists in database
def check_email_exists(cursor, email):
    q = ("SELECT COUNT(*) FROM Users WHERE email = %s")
    cursor.execute(q, (email,))
    return cursor.fetchone()[0] > 0

# inserts a new user record into database
def insert_sign_up_info(cursor, f_name, l_name, city, state, email, university, password):
    # query to insert a new user record
    q = ('INSERT INTO Users (f_name, l_name, city, state, email, university, password)'
         'VALUES (%s, %s, %s, %s, %s, %s, %s)')
    
    # execute query with parameterized values
    cursor.execute(q, (f_name, l_name, city, state, email, university, password))
    