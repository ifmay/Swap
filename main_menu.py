# ======================================================================
#
# NAME:     Isabelle May
# ASSIGN:   Final Project
# COURSE:   CPSC 321, Fall 2024
# DESC:     This module provides the interface for the SWAP application.
#           It includes the main menu and the SWAP ASCII logo, allowing
#           users to navigate between core features like profile management,
#           browsing items or job listings, recording transactions, messaging,
#           ratings, and platform analytics. The module ensures a user-friendly
#           interface and seamless integration with other components.
#
# ======================================================================

def print_swap():
    """
    Print the SWAP logo as ASCII art.

    This function outputs an ASCII art representation of the SWAP logo.
    """
    art = """
  ███   ██     ██  █████  ██████  
 ██     ██     ██ ██   ██ ██   ██ 
  ███   ██  █  ██ ███████ ██████  
    ██  ██ ███ ██ ██   ██ ██      
  ███    ███ ███  ██   ██ ██   
    """
    print(art)

# Prints main menu of the program
def main_menu():
    """
    Display the main menu and return the user's choice.

    This function prints the SWAP logo followed by a menu of options for the
    user to interact with the program. It then prompts the user for input
    to select one of the menu options.

    Returns:
        str: The user's choice as a string.
    """
    print_swap()
    print("\nMain Menu:")
    print("1. My Profile")
    print("2. Browse Items")
    print("3. Browse Job Listings")
    print("4. Record a Transaction")
    print("5. Messages")
    print("6. Ratings")
    print("7. Platform Analytics")
    print("8. Exit")

    choice = input("Choose an option: ")
    return choice
