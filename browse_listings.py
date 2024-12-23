# ======================================================================
#
# NAME:     Isabelle May
# ASSIGN:   Final Project
# COURSE:   CPSC 321, Fall 2024
# DESC:     This module enables users to browse available job listings based
#           on specific criteria such as skill type, date posted, and
#           freelancer ratings. It also provides functionality to view
#           detailed information about freelancers associated with each job
#           listing. Users can filter job listings according to their
#           preferences and explore detailed profiles of freelancers to make
#           informed decisions about potential job opportunities.
#
# ======================================================================

def browse_listings(cursor, user_email):
    """
    Display browsing options for job listings in the user's city.
    """
    # Query to retrieve user information, including their city
    q = """
    SELECT f_name, l_name, email, city
    FROM Users
    WHERE email = %s;
    """
    cursor.execute(q, (user_email,))
    user = cursor.fetchone()

    if user:
        user_city = user[3]  # Extract the user's city
        print("\n--- Job Listings ---")

        while True:
            print("View Options:")
            print("1. Sort By Skill Type")
            print("2. Sort By Date Posted")
            print("3. Sort By Highest Rating")
            print("4. View Freelancer's Information")
            print("5. Back to Main Menu")
            choice = input("Choose an option: ")

            if choice == "1":
                sort_by_skill_type(cursor, user_email, user_city)
            elif choice == "2":
                sort_by_date_posted_jobs(cursor, user_email, user_city)
            elif choice == "3":
                sort_by_freelancer_rating(cursor, user_email, user_city)
            elif choice == "4":
                view_freelancer_info(cursor, user_email)
            elif choice == "5":
                return
            else:
                print("Invalid option. Please try again.")
    else:
        print("Error: Unable to fetch profile information.")

def sort_by_skill_type(cursor, user_email, user_city):
    """
    Display job listings filtered by a skill type selected by the user in their city.
    """
    # List of skill types and descriptions
    skill_types = [
        "Web Development",
        "Data Analysis",
        "Public Speaking",
        "Programming",
        "Graphic Design",
        "Problem Solving",
        "Project Management",
        "Writing",
        "Critical Thinking",
        "Networking",
        "Research",
        "Event Planning",
        "Marketing",
        "Social Media Management",
        "Foreign Language",
        "Technical Writing",
        "Coding",
        "User Experience Design",
        "Cybersecurity",
        "Machine Learning",
        "Video Editing",
        "3D Modeling",
        "Tutoring",
        "Babysitting",
        "Lawn Mowing",
        "Pet Sitting",
        "House Cleaning",
        "Errand Running",
        "Car Washing",
        "Snow Removal",
        "Photography",
        "Accounting"
    ]

    # Display the skill types with corresponding numbers
    print("\n--- Select a Skill Type ---")
    for i, skill in enumerate(skill_types, 1):
        print(f"{i}. {skill}")

    # Get the user's choice
    try:
        choice = int(input("Enter the number corresponding to your skill type: "))
        if choice < 1 or choice > len(skill_types):
            raise ValueError
    except ValueError:
        print("Invalid selection. Please enter a number corresponding to a skill type.")
        return

    # Get the selected skill type
    selected_skill_type = skill_types[choice - 1]

    # Query to fetch job listings based on the selected skill type
    q = """
    SELECT job_id, skill_type, description, payment
    FROM FreelanceWork
    WHERE skill_type = %s AND posted_by != %s AND posted_by IN (
        SELECT email FROM Users WHERE city = %s
    );
    """
    cursor.execute(q, (selected_skill_type, user_email, user_city))
    jobs = cursor.fetchall()

    # Display the job listings
    print(f"\n--- Job Listings for '{selected_skill_type}' ---")
    if jobs:
        for job in jobs:
            print(f"ID: {job[0]}, Skill: {job[1]}")
            print(f"Description: {job[2]}")
            print(f"Payment: ${job[3]:.2f}/hour")
            print("-" * 40)
    else:
        print(f"No job listings found for the skill type '{selected_skill_type}'.")

def sort_by_date_posted_jobs(cursor, user_email, user_city):
    """
    Display job listings sorted by date posted.
    """
    q = """
    SELECT job_id, skill_type, description, payment, created_at
    FROM FreelanceWork
    WHERE posted_by != %s AND posted_by IN (
        SELECT email FROM Users WHERE city = %s
    )
    ORDER BY created_at DESC;
    """
    cursor.execute(q, (user_email, user_city))
    jobs = cursor.fetchall()
    print("\n--- Job Listings Sorted by Date Posted ---")
    if jobs:
        for job in jobs:
            print(f"ID: {job[0]}, Skill: {job[1]}")
            print(f"Description: {job[2]}")
            print(f"Payment: ${job[3]:.2f}/hour")
            print(f"Date Posted: {job[4]}")
            print("-" * 40)
    else:
        print("No job listings found.")

def sort_by_freelancer_rating(cursor, user_email, user_city):
    """
    Display job listings sorted by the highest freelancer rating.
    """
    q = """
    SELECT FW.job_id, FW.skill_type, FW.description, FW.payment, U.f_name, U.l_name, U.rating
    FROM FreelanceWork FW
    JOIN Users U ON FW.posted_by = U.email
    WHERE FW.posted_by != %s AND U.city = %s
    ORDER BY U.rating DESC;
    """
    cursor.execute(q, (user_email, user_city))
    jobs = cursor.fetchall()
    print("\n--- Job Listings Sorted by Freelancer Rating ---")
    if jobs:
        for job in jobs:
            print(f"Job ID: {job[0]}, Skill: {job[1]}")
            print(f"Description: {job[2]}")
            print(f"Payment: ${job[3]:.2f}/hour")
            print(f"Freelancer: {job[4]} {job[5]}, Rating: {job[6]:.2f}")
            print("-" * 40)
    else:
        print("No job listings found.")

def view_freelancer_info(cursor, user_email):
    """
    Display the profile information of a freelancer based on a selected job listing.

    Args:
        cursor: The database cursor object to execute queries.
    """
    # Query to fetch all active job listings
    listings_query = """
    SELECT job_id, skill_type, description, payment, posted_by
    FROM FreelanceWork
    WHERE posted_by != %s
    ORDER BY created_at DESC;
    """
    cursor.execute(listings_query, (user_email,))
    jobs = cursor.fetchall()

    if jobs:
        print("\n--- Available Job Listings ---")
        for i, job in enumerate(jobs, 1):
            print(f"{i}. Job ID: {job[0]}, Skill: {job[1]}, Payment: ${job[3]:.2f}/hour, Posted By: {job[4]}")

        try:
            choice = int(input("\nSelect a job by number to view freelancer information: "))
            
            if 1 <= choice <= len(jobs):
                selected_job = jobs[choice - 1]
                freelancer_email = selected_job[4]

                # Query to fetch the freelancer's information
                user_info_query = """
                SELECT f_name, l_name, email, city, state, rating
                FROM Users
                WHERE email = %s;
                """
                cursor.execute(user_info_query, (freelancer_email,))
                freelancer = cursor.fetchone()

                if freelancer:
                    print("\n--- Freelancer Information ---")
                    print(f"Name: {freelancer[0]} {freelancer[1]}")
                    print(f"Email: {freelancer[2]}")
                    print(f"City: {freelancer[3]}, State: {freelancer[4]}")
                    print(f"Seller Rating: {freelancer[5]:.2f}")
                else:
                    print("Error: Unable to fetch freelancer information.")
            else:
                print("Invalid selection. Please choose a valid job listing number.")
        except ValueError:
            print("Invalid input. Please enter a number corresponding to a job listing.")
    else:
        print("No job listings available at the moment.")
