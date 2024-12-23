# ======================================================================
#
# NAME:     Isabelle May
# ASSIGN:   Final Project
# COURSE:   CPSC 321, Fall 2024
# DESC:      A Python program that provides platform-wide analytics for 
#            an e-commerce and freelance work system. This module allows 
#            administrators or users to gain insights into platform activity 
#            through data queries, such as active users, total sales by category,
#           average prices, and top performers.
#
# ======================================================================

def platform_analytics(cursor):
    """Display options for running various platform data analysis queries."""
    while True:
        print("\nPlatform Analytics Options:")
        print("1. Active Users this Year")
        print("2. Total Sales by Item Category")
        print("3. Average Item Price by Seller")
        print("4. Most Active Sellers by Transaction")
        print("5. Top Buyers")
        print("6. Back to Profile Menu")
        choice = input("Choose an analysis option: ")

        if choice == "1":
            display_active_users(cursor)
        elif choice == "2":
            display_total_sales_by_category(cursor)
        elif choice == "3":
            display_avg_price_by_seller(cursor)
        elif choice == "4":
            display_most_transactions(cursor)
        elif choice == "5":
            display_top_item_buyers(cursor)
        elif choice == "6":
            print("Returning to Profile Menu...")
            break
        else:
            print("Invalid option. Please try again.")

def display_active_users(cursor):
    """Display the number of active users this year."""
    query = """
        SELECT COUNT(DISTINCT u.email) AS active_users
        FROM Users u
        WHERE u.email IN (
            SELECT DISTINCT i.seller_email
            FROM ItemsForSale i
            WHERE i.created_at BETWEEN '2024-01-01' AND '2024-12-31'
        );
    """
    cursor.execute(query)
    result = cursor.fetchone()
    print(f"\nActive Users in the Last Month: {result[0]}")

def display_total_sales_by_category(cursor):
    """Display total sales grouped by item category."""
    query = """
        SELECT i.item_type, SUM(it.amount_paid) AS total_sales
        FROM ItemTransactions it
        JOIN ItemsForSale i ON it.item_id = i.item_id
        WHERE it.date_completed BETWEEN '2024-01-01' AND '2024-12-31'
        GROUP BY i.item_type
        ORDER BY total_sales DESC;
    """
    cursor.execute(query)
    results = cursor.fetchall()
    print("\nTotal Sales by Item Category:")
    for row in results:
        print(f"Category: {row[0]}, Total Sales: ${row[1]:.2f}")

def display_avg_price_by_seller(cursor):
    """Display the average item price for each seller."""
    query = """
        SELECT i.seller_email, AVG(i.price) AS avg_item_price
        FROM ItemsForSale i
        WHERE i.availability_status = TRUE
        GROUP BY i.seller_email
        ORDER BY avg_item_price DESC;
    """
    cursor.execute(query)
    results = cursor.fetchall()
    print("\nAverage Item Price by Seller:")
    for row in results:
        print(f"Seller: {row[0]}, Average Price: ${row[1]:.2f}")
        
def display_most_transactions(cursor):
    """Display users with the most transactions as sellers."""
    query = """
        WITH ItemSellerTransactions AS (
            SELECT it.seller_email AS email, COUNT(it.transaction_id) AS transactions_count
            FROM ItemTransactions it
            GROUP BY it.seller_email
        ),
        FreelanceWorkerTransactions AS (
            SELECT ft.worker_email AS email, COUNT(ft.transaction_id) AS transactions_count
            FROM FreelanceTransactions ft
            GROUP BY ft.worker_email
        ),
        CombinedTransactions AS (
            SELECT email, SUM(transactions_count) AS total_transactions
            FROM (
                SELECT * FROM ItemSellerTransactions
                UNION ALL
                SELECT * FROM FreelanceWorkerTransactions
            ) subquery
            GROUP BY email
        )
        SELECT email, total_transactions
        FROM CombinedTransactions
        ORDER BY total_transactions DESC
        LIMIT 10;
    """
    cursor.execute(query)
    results = cursor.fetchall()
    print("\nTop Sellers by Transactions:")
    for row in results:
        print(f"Seller: {row[0]}, Transactions: {row[1]}")

def display_top_item_buyers(cursor):
    """Display the top 10 buyers with their total and average spending per transaction."""
    query = """
        WITH BuyerSpending AS (
            SELECT 
                it.buyer_email,
                COUNT(it.transaction_id) AS transaction_count,
                SUM(it.amount_paid) AS total_spent,
                AVG(it.amount_paid) AS avg_spent_per_transaction,
                RANK() OVER (ORDER BY SUM(it.amount_paid) DESC) AS rank
            FROM ItemTransactions it
            WHERE it.date_completed BETWEEN '2024-01-01' AND '2024-12-31'
            GROUP BY it.buyer_email
        )
        SELECT 
            buyer_email,
            transaction_count,
            total_spent,
            avg_spent_per_transaction
        FROM BuyerSpending
        WHERE rank <= 10
        ORDER BY rank;
    """
    cursor.execute(query)
    results = cursor.fetchall()
    print("\nTop 10 Buyers(2024):")
    for row in results:
        print(
            f"Buyer: {row[0]}, "
            f"Transactions: {row[1]}, "
            f"Total Spent: ${row[2]:.2f}, "
            f"Avg Spending: ${row[3]:.2f}"
        )
