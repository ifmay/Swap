# pylint: skip-file
# ======================================================================
#
# NAME:     Isabelle May
# ASSIGN:   Final Project
# COURSE:   CPSC 321, Fall 2024
# DESC:    This program serves as the entry point for the SWAP platform, 
#          an e-commerce and freelance work application. It integrates
#          multiple modules to provide functionality such as user login
#          and signup, profile management, browsing and managing items
#          or freelance listings, recording transactions, messaging,
#          ratings, and platform-wide analytics. The program establishes
#          a PostgreSQL database connection and ensures that all user
#          interactions are processed securely and efficiently.
#
# ======================================================================

import psycopg as pg
import config

import main_menu
import login
from user_profile import profile
from browse_items import browse_items
from browse_listings import browse_listings
from record_transaction import record_transaction
from browse_messages import browse_messages
from ratings import ratings
from platform_analytics import platform_analytics

# Main function to connect to the database and handle user interactions.
def main():
    # Connection info from the config file
    hst = config.HOST
    usr = config.USER
    pwd = config.PASSWORD
    dat = config.DATABASE

    try:
        with pg.connect(host=hst, user=usr, password=pwd, dbname=dat) as cn:
            print("Successfully connected to the database.")
            with cn.cursor() as cursor:
                logged_in_email = None
                while not logged_in_email:
                    main_menu.print_swap()
                    print("\nWelcome to SWAP!")
                    print("1. Login")
                    print("2. Signup")
                    choice = input("Choose an option: ")
                    if choice == "1":
                        logged_in_email = login.log_in(cursor)
                    elif choice == "2":
                        logged_in_email = login.sign_up(cursor)
                    else:
                        print("Invalid option. Please try again.")

                while True:
                    choice = main_menu.main_menu()
                    if choice == "1":
                        profile(cursor, logged_in_email)
                    elif choice == "2":
                        browse_items(cursor, logged_in_email)
                    elif choice == "3":
                        browse_listings(cursor, logged_in_email)
                    elif choice == "4":
                        record_transaction(cursor, logged_in_email)
                    elif choice == "5":
                        browse_messages(cursor, logged_in_email)
                    elif choice == "6":
                        ratings(cursor, logged_in_email)
                    elif choice == "7":
                        platform_analytics(cursor)
                    elif choice =="8":
                        print("Exiting SWAP. Goodbye!")
                        break
                    else:
                        print("Invalid option. Please try again.")

                    # Commit transaction after each operation
                    cn.commit()

    except Exception as e:
        print(f"Failed to connect to the database: {e}")

if __name__ == '__main__':
    main()