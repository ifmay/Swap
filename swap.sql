-- Drop existing tables to avoid conflicts
DROP TABLE IF EXISTS ItemRatings CASCADE;               -- Depends on Users
DROP TABLE IF EXISTS FreelanceWorkRatings CASCADE;      -- Depends on Users
DROP TABLE IF EXISTS Messages CASCADE;                 -- Depends on Users
DROP TABLE IF EXISTS FreelanceTransactions CASCADE;    -- Depends on FreelanceWork and Users
DROP TABLE IF EXISTS ItemTransactions CASCADE;         -- Depends on ItemsForSale and Users
DROP TABLE IF EXISTS FreelanceWork CASCADE;            -- Depends on Users
DROP TABLE IF EXISTS ItemsForSale CASCADE;             -- Depends on Users
DROP TABLE IF EXISTS Skills CASCADE;                   -- Independent
DROP TABLE IF EXISTS ItemTypes CASCADE;                -- Independent
DROP TABLE IF EXISTS Users CASCADE;                    -- Parent table, drop last


CREATE TABLE Users (
    email VARCHAR(150) PRIMARY KEY,    -- User's email (must be unique)
    f_name VARCHAR(100) NOT NULL,          -- User's first name
    l_name VARCHAR(100) NOT NULL,          -- User's last name
    city VARCHAR(100),                     -- User's city
    state VARCHAR(2),                      -- User's state code
    university VARCHAR(100),               -- University, if null = community member/non-student
    password VARCHAR(100),                 -- User's password
    rating DECIMAL(3, 2) DEFAULT 0.00 -- User's Rating
);

CREATE TABLE ItemTypes (
    type_name VARCHAR(100) PRIMARY KEY, -- Name of the category (e.g., "Furniture", "Textbooks")
    description TEXT                         -- Description of the type
);

CREATE TABLE ItemsForSale (
    item_id SERIAL PRIMARY KEY,               -- Unique identifier for each item
    item_type VARCHAR(100) NOT NULL,           -- Type of item (e.g., furniture, textbooks)
    item_description TEXT NOT NULL,                -- Description of the item
    price DECIMAL(10, 2) NOT NULL,            -- Price of the item (e.g., 1234.56)
    seller_email VARCHAR(150) NOT NULL,                   -- Foreign key referencing the Users table
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the item was listed
    availability_status BOOLEAN DEFAULT TRUE,         -- Availability
    FOREIGN KEY (seller_email) REFERENCES Users(email), -- Establish relationship with Users table
    FOREIGN KEY (item_type) REFERENCES ItemTypes(type_name)
);

CREATE TABLE Skills (
    skill_type VARCHAR(100) PRIMARY KEY,     -- Name of the skill (e.g., "Web Development")
    description TEXT                         -- Optional description of the skill
);

CREATE TABLE FreelanceWork (
    job_id SERIAL PRIMARY KEY,              -- Unique identifier for each job listing
    skill_type VARCHAR(100) NOT NULL,         -- Type of skill/job (e.g., web development, marketing)
    description TEXT NOT NULL,               -- Detailed description of the job
    payment DECIMAL(10, 2) NOT NULL,         -- Payment amount (e.g., 1234.56) per hour
    posted_by VARCHAR(150) NOT NULL,                  -- Foreign key referencing the Users table
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the job was listed
    FOREIGN KEY (posted_by) REFERENCES Users(email),  -- Link to the user posting the job
    FOREIGN KEY (skill_type) REFERENCES SKills(skill_type) -- Link to the type of skill offered
);

CREATE TABLE ItemTransactions (
    transaction_id SERIAL PRIMARY KEY,       -- Unique identifier for each transaction
    item_id INT NOT NULL,                     -- Foreign key referencing the item_id from ItemsForSale
    buyer_email VARCHAR(150) NOT NULL,        -- Foreign key referencing the buyer (Users table)
    seller_email VARCHAR(150) NOT NULL,       -- Foreign key referencing the seller (Users table)
    amount_paid DECIMAL(10, 2) NOT NULL,      -- The amount paid in the transaction
    date_completed TIMESTAMP DEFAULT NOW(), -- Date and time the transaction was completed
    FOREIGN KEY (item_id) REFERENCES ItemsForSale(item_id),  -- Foreign key to ItemsForSale
    FOREIGN KEY (buyer_email) REFERENCES Users(email),   -- Link to the buyer in the Users table
    FOREIGN KEY (seller_email) REFERENCES Users(email)   -- Link to the seller in the Users table
);

CREATE TABLE FreelanceTransactions (
    transaction_id SERIAL PRIMARY KEY,       -- Unique identifier for each transaction
    job_id INT NOT NULL,                     -- Foreign key referencing the item_id from ItemsForSale
    buyer_email VARCHAR(150) NOT NULL,        -- Foreign key referencing the buyer (Users table)
    worker_email VARCHAR(150) NOT NULL,       -- Foreign key referencing the seller (Users table)
    amount_paid DECIMAL(10, 2) NOT NULL,      -- The amount paid in the transaction
    date_completed TIMESTAMP DEFAULT NOW(),   -- Date and time the transaction was completed
    FOREIGN KEY (job_id) REFERENCES FreelanceWork(job_id),  -- Foreign key to ItemsForSale
    FOREIGN KEY (buyer_email) REFERENCES Users(email),   -- Link to the buyer in the Users table
    FOREIGN KEY (worker_email) REFERENCES Users(email)   -- Link to the seller in the Users table
);

CREATE TABLE ItemRatings (
    item_id SERIAL PRIMARY KEY,                          -- Unique identifier for each listing
    rater_email VARCHAR(150) NOT NULL,                  -- Foreign key to Users (user rating the seller)
    rating_email VARCHAR(150) NOT NULL,                 -- Foreign key to Users (seller being rated)
    rating DECIMAL(3, 2) CHECK (rating BETWEEN 0 AND 5.0), -- Rating (0.00 to 5.00)
    review TEXT,                                   -- Optional review text
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp for when the rating was given
    FOREIGN KEY (item_id) REFERENCES ItemsForSale(item_id), -- Link to the rated item
    FOREIGN KEY (rater_email) REFERENCES Users(email), -- Link to the user rating the seller
    FOREIGN KEY (rating_email) REFERENCES Users(email) -- Link to the seller being rated
);

CREATE TABLE FreelanceWorkRatings (
    freelance_job_id INT NOT NULL,                 -- Foreign key referencing FreelanceWork
    rater_email VARCHAR(150) NOT NULL,                         -- Foreign key referencing the user who is rating
    rating_email VARCHAR(150) NOT NULL,                         -- Foreign key referencing the freelancer being rated
    rating DECIMAL(3, 2) CHECK (rating BETWEEN 0 AND 5.0), -- Rating scale 0 to 5
    review TEXT,                                   -- Optional review text
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp for when the rating was given
    FOREIGN KEY (freelance_job_id) REFERENCES FreelanceWork(job_id) ON DELETE CASCADE,  -- Link to freelance job
    FOREIGN KEY (rater_email) REFERENCES Users(email) ON DELETE CASCADE, -- Link to the rater (client)
    FOREIGN KEY (rating_email) REFERENCES Users(email) ON DELETE CASCADE -- Link to the freelancer being rated
);

CREATE TABLE Messages (
    message_id SERIAL PRIMARY KEY,               -- Unique ID for each message
    sender_email VARCHAR(150) NOT NULL,                      -- Foreign key referencing the sender (Users table)
    recipient_email VARCHAR(150) NOT NULL,                   -- Foreign key referencing the recipient (Users table)
    message_content TEXT NOT NULL,              -- The message content
    date_sent TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the message was sent
    is_read BOOLEAN DEFAULT FALSE,              -- Indicates whether the message has been read
    FOREIGN KEY (sender_email) REFERENCES Users(email),  -- Link to the sender in the Users table
    FOREIGN KEY (recipient_email) REFERENCES Users(email) -- Link to the recipient in the Users table
);

INSERT INTO Users (f_name, l_name, city, state, email, university, password, rating) 
VALUES 
('Jane', 'Smith', 'Spokane', 'WA', 'jane.smith@gonzaga.edu', 'Gonzaga University', 'securePass!', 4.50),
('Sarah', 'Davis', 'Spokane', 'WA', 'davis@gonzaga.com', 'Gonzaga University', 'ilovecoding', 4.90),
('Izzy', 'May', 'Spokane', 'WA', 'imay@gonzaga.edu', 'Gonzaga University', '12345', 4.90), 
('Alice', 'Green', 'Spokane', 'WA', 'alice.green@gonzaga.edu', 'Gonzaga University', 'password1!', 4.80),
('Robert', 'Clark', 'Spokane', 'WA', 'robert.clark@gonzaga.edu', 'Gonzaga University', 'abc123!', 4.70),
('Jessica', 'White', 'Spokane', 'WA', 'jessica.white@gonzaga.edu', 'Gonzaga University', 'securePass2', 4.60),
('William', 'King', 'Spokane', 'WA', 'william.king@gonzaga.edu', 'Gonzaga University', 'mySecurePass', 4.50),
('Ella', 'Adams', 'Spokane', 'WA', 'ella.adams@gonzaga.edu', 'Gonzaga University', 'helloGonzaga1', 4.90),
('Henry', 'Baker', 'Spokane', 'WA', 'henry.baker@gonzaga.edu', 'Gonzaga University', 'GZPass2024!', 4.85),
('Amelia', 'Brown', 'Spokane', 'WA', 'amelia.brown@gonzaga.edu', 'Gonzaga University', 'P@ssword567', 4.75),
('Oliver', 'Evans', 'Spokane', 'WA', 'oliver.evans@gonzaga.edu', 'Gonzaga University', 'secureGZ!', 4.55),
('Sophia', 'Hill', 'Spokane', 'WA', 'sophia.hill@gonzaga.edu', 'Gonzaga University', 'HillTop1!', 4.65),
('James', 'Harris', 'Spokane', 'WA', 'james.harris@gonzaga.edu', 'Gonzaga University', 'GonzagaIsGreat', 4.50),
('Lily', 'Kelly', 'Spokane', 'WA', 'lily.kelly@gonzaga.edu', 'Gonzaga University', 'GoBulldogs1', 4.80),
('Logan', 'Reed', 'Spokane', 'WA', 'logan.reed@gonzaga.edu', 'Gonzaga University', 'secureMyPass!', 4.70),
('Emily', 'Morgan', 'Spokane', 'WA', 'emily.morgan@gonzaga.edu', 'Gonzaga University', 'SafePass2024', 4.90),
('Daniel', 'Diaz', 'Spokane', 'WA', 'daniel.diaz@gonzaga.edu', 'Gonzaga University', 'MyP@ss4GZ', 4.95),
('Grace', 'Long', 'Spokane', 'WA', 'grace.long@gonzaga.edu', 'Gonzaga University', 'PasswordLong1', 4.85),
('Lucas', 'Ross', 'Spokane', 'WA', 'lucas.ross@gonzaga.edu', 'Gonzaga University', 'NewPass2025!', 4.40),
('Mia', 'Sanders', 'Spokane', 'WA', 'mia.sanders@gonzaga.edu', 'Gonzaga University', 'Mia123!', 4.65),
('Jack', 'Barnes', 'Spokane', 'WA', 'jack.barnes@gonzaga.edu', 'Gonzaga University', 'JackIsBack!', 4.75),
('Chloe', 'Murphy', 'Spokane', 'WA', 'chloe.murphy@gonzaga.edu', 'Gonzaga University', 'Murphy!22', 4.90),
('Benjamin', 'Cook', 'Spokane', 'WA', 'benjamin.cook@gonzaga.edu', 'Gonzaga University', 'Cooking2024', 4.30),
('Harper', 'Gray', 'Spokane', 'WA', 'harper.gray@gonzaga.edu', 'Gonzaga University', 'GraySky1!', 4.85),
('Elijah', 'Wright', 'Spokane', 'WA', 'elijah.wright@gonzaga.edu', 'Gonzaga University', 'PasswordEli', 4.60),
('Avery', 'Hughes', 'Spokane', 'WA', 'avery.hughes@gonzaga.edu', 'Gonzaga University', 'Hughes42', 4.75),
('Charlotte', 'Brooks', 'Spokane', 'WA', 'charlotte.bsrooks@gonzaga.edu', 'Gonzaga University', 'GoGonzaga!', 4.95),
('Henry', 'Price', 'Spokane', 'WA', 'henry.price@gonzaga.edu', 'Gonzaga University', 'Secure1234!', 4.70),
('Ella', 'Carter', 'Boulder', 'CO', 'ella.carter@colorado.edu', 'University of Colorado', 'EllaPass2024!', 4.80),
('Alexander', 'Turner', 'Boulder', 'CO', 'alexander.turner@colorado.edu', 'University of Colorado', 'TurnerTigers!', 4.65),
('Isabella', 'Parker', 'Boulder', 'CO', 'isabella.parker@colorado.edu', 'University of Colorado', 'SafePass!23', 4.90),
('Mason', 'Collins', 'Boulder', 'CO', 'mason.collins@colorado.edu', 'University of Colorado', 'Collins24', 4.70),
('Charlotte', 'Simmons', 'Boulder', 'CO', 'charlotte.simmons@colorado.edu', 'University of Colorado', 'SimSecure1!', 4.75),
('Oliver', 'Bennett', 'Boulder', 'CO', 'oliver.bennett@colorado.edu', 'University of Colorado', 'SecureOliver2024', 4.95),
('Ava', 'Wright', 'Boulder', 'CO', 'ava.wright@colorado.edu', 'University of Colorado', 'WrightHere1!', 4.50),
('Henry', 'Green', 'Boulder', 'CO', 'henry.green@colorado.edu', 'University of Colorado', 'GreenLife24', 4.85),
('Mia', 'Ward', 'Boulder', 'CO', 'mia.ward@colorado.edu', 'University of Colorado', 'WardPass1', 4.60),
('Logan', 'Foster', 'Boulder', 'CO', 'logan.foster@colorado.edu', 'University of Colorado', 'HelloFoster!', 4.75),
('Emily', 'James', 'Boulder', 'CO', 'emily.james@colorado.edu', 'University of Colorado', 'JamesSecure!', 4.95),
('Lucas', 'Gray', 'Boulder', 'CO', 'lucas.gray@colorado.edu', 'University of Colorado', 'Lucas42!', 4.40),
('Lily', 'Cruz', 'Boulder', 'CO', 'lily.cruz@colorado.edu', 'University of Colorado', 'CruzRocks!', 4.65),
('Noah', 'Barnes', 'Boulder', 'CO', 'noah.barnes@colorado.edu', 'University of Colorado', 'BarnesHere123', 4.75),
('Sophia', 'Peterson', 'Boulder', 'CO', 'sophia.peterson@colorado.edu', 'University of Colorado', 'Peterson23', 4.90),
('Jackson', 'Butler', 'Boulder', 'CO', 'jackson.butler@colorado.edu', 'University of Colorado', 'ButlerSecure1!', 4.30),
('Chloe', 'Brooks', 'Boulder', 'CO', 'chloe.brooks@colorado.edu', 'University of Colorado', 'Brooks42!', 4.85),
('Benjamin', 'Cook', 'Boulder', 'CO', 'benjamin.cook@colorado.edu', 'University of Colorado', 'CookLife123', 4.60),
('Harper', 'Price', 'Boulder', 'CO', 'harper.price@colorado.edu', 'University of Colorado', 'Price42!', 4.75),
('Elijah', 'Murphy', 'Boulder', 'CO', 'elijah.murphy@colorado.edu', 'University of Colorado', 'MurphySecure1!', 4.95),
('Avery', 'Sanders', 'Boulder', 'CO', 'avery.sanders@colorado.edu', 'University of Colorado', 'SandersSecure!', 4.70),
('Charlotte', 'Ross', 'Boulder', 'CO', 'charlotte.ross@colorado.edu', 'University of Colorado', 'RossSecure123', 4.65),
('Henry', 'Barnes', 'Boulder', 'CO', 'henry.barnes@colorado.edu', 'University of Colorado', 'BarnesHere!', 4.75),
('Isabella', 'Morgan', 'Boulder', 'CO', 'isabella.morgan@colorado.edu', 'University of Colorado', 'MorganSecure!', 4.90),
('Mason', 'Evans', 'Boulder', 'CO', 'mason.evans@colorado.edu', 'University of Colorado', 'EvansPass123!', 4.30), 
('Ethan', 'Reed', 'Seattle', 'WA', 'ethan.reed@uw.edu', 'University of Washington', 'ReedSecure1!', 4.80),
('Olivia', 'Cole', 'Seattle', 'WA', 'olivia.cole@uw.edu', 'University of Washington', 'Cole123Pass!', 4.65),
('James', 'Adams', 'Seattle', 'WA', 'james.adams@uw.edu', 'University of Washington', 'AdamsSecure!', 4.90),
('Sophia', 'Hill', 'Seattle', 'WA', 'sophia.hill@uw.edu', 'University of Washington', 'HillSecure23!', 4.70),
('Logan', 'Scott', 'Seattle', 'WA', 'logan.scott@uw.edu', 'University of Washington', 'ScottPass123', 4.75),
('Emma', 'Mitchell', 'Seattle', 'WA', 'emma.mitchell@uw.edu', 'University of Washington', 'Mitchell2024!', 4.95),
('Daniel', 'Cox', 'Seattle', 'WA', 'daniel.cox@uw.edu', 'University of Washington', 'CoxSecure42', 4.50),
('Avery', 'Gonzalez', 'Seattle', 'WA', 'avery.gonzalez@uw.edu', 'University of Washington', 'GonzalezSecure!', 4.85),
('Jacob', 'Diaz', 'Seattle', 'WA', 'jacob.diaz@uw.edu', 'University of Washington', 'DiazSecure1!', 4.60),
('Lily', 'Perry', 'Seattle', 'WA', 'lily.perry@uw.edu', 'University of Washington', 'PerryLife!', 4.75),
('Lucas', 'Henderson', 'Seattle', 'WA', 'lucas.henderson@uw.edu', 'University of Washington', 'Henderson42!', 4.95),
('Ella', 'Howard', 'Seattle', 'WA', 'ella.howard@uw.edu', 'University of Washington', 'HowardPass123!', 4.40),
('Mason', 'Bell', 'Seattle', 'WA', 'mason.bell@uw.edu', 'University of Washington', 'BellLife24!', 4.65),
('Chloe', 'Patterson', 'Seattle', 'WA', 'chloe.patterson@uw.edu', 'University of Washington', 'PattersonSecure42!', 4.75),
('Noah', 'Simmons', 'Seattle', 'WA', 'noah.simmons@uw.edu', 'University of Washington', 'Simmons123!', 4.90),
('Charlotte', 'Edwards', 'Seattle', 'WA', 'charlotte.edwards@uw.edu', 'University of Washington', 'EdwardsPass!', 4.30),
('Ethan', 'Harris', 'Seattle', 'WA', 'ethan.harris@uw.edu', 'University of Washington', 'HarrisLife1!', 4.85),
('Isabella', 'Ward', 'Seattle', 'WA', 'isabella.ward@uw.edu', 'University of Washington', 'WardSecure2024', 4.60),
('Ava', 'Kelly', 'Seattle', 'WA', 'ava.kelly@uw.edu', 'University of Washington', 'Kelly42Secure!', 4.75),
('Henry', 'Rivera', 'Seattle', 'WA', 'henry.rivera@uw.edu', 'University of Washington', 'RiveraSecure23!', 4.95),
('Mia', 'Richardson', 'Seattle', 'WA', 'mia.richardson@uw.edu', 'University of Washington', 'Richardson2024!', 4.70),
('Liam', 'King', 'Seattle', 'WA', 'liam.king@uw.edu', 'University of Washington', 'KingSecure1!', 4.65),
('Olivia', 'Baker', 'Seattle', 'WA', 'olivia.baker@uw.edu', 'University of Washington', 'BakerPass42!', 4.75),
('Elijah', 'Griffin', 'Seattle', 'WA', 'elijah.griffin@uw.edu', 'University of Washington', 'GriffinSecure!', 4.90),
('Charlotte', 'Watson', 'Seattle', 'WA', 'charlotte.watson@uw.edu', 'University of Washington', 'WatsonSecure!', 4.30), 
('John', 'Doe', 'Seattle', 'WA', 'john.doe@gmail.com', NULL, 'password123', 4.75),
('Olivia', 'Taylor', 'Spokane', 'WA', 'olivia.taylor@gmail.com', NULL, 'TaylorPass42!', 4.80),
('William', 'Martinez', 'Seattle', 'WA', 'william.martinez@gmail.com', NULL, 'MartinezSecure1!', 4.65),
('Sophia', 'Anderson', 'Boulder', 'CO', 'sophia.anderson@gmail.com', NULL, 'AndersonSecure23!', 4.90),
('James', 'Thomas', 'Seattle', 'WA', 'james.thomas@gmail.com', NULL, 'ThomasLife123!', 4.70),
('Amelia', 'White', 'Spokane', 'WA', 'amelia.white@gmail.com', NULL, 'WhiteSecure1!', 4.75),
('Elijah', 'Harris', 'Seattle', 'WA', 'elijah.harris@gmail.com', NULL, 'Harris42Pass!', 4.95),
('Isabella', 'Clark', 'Boulder', 'CO', 'isabella.clark@gmail.com', NULL, 'ClarkLife!', 4.50),
('Liam', 'Lewis', 'Spokane', 'WA', 'liam.lewis@gmail.com', NULL, 'LewisSecure!', 4.85),
('Emily', 'Johnson', 'Spokane', 'WA', 'emily.j@gmail.com', NULL, 'myP@ssword1', 4.80),
('Michael', 'Brown', 'Spokane', 'WA', 'michael.b@gonzaga.edu', NULL, 'password1234', 4.20),
('Mia', 'Walker', 'Seattle', 'WA', 'mia.walker@gmail.com', NULL, 'WalkerSecure24!', 4.60),
('Noah', 'Young', 'Boulder', 'CO', 'noah.young@gmail.com', NULL, 'Young123Pass!', 4.75),
('Emily', 'Hall', 'Seattle', 'WA', 'emily.hall@gmail.com', NULL, 'HallSecure42!', 4.95),
('Henry', 'Allen', 'Spokane', 'WA', 'henry.allen@gmail.com', NULL, 'Allen42Secure!', 4.40),
('Ava', 'Lopez', 'Seattle', 'WA', 'ava.lopez@gmail.com', NULL, 'LopezSecure1!', 4.65),
('Sophia', 'Hill', 'Boulder', 'CO', 'sophia.hill@gmail.com', NULL, 'HillLife123!', 4.75),
('Ethan', 'Scott', 'Spokane', 'WA', 'ethan.scott@gmail.com', NULL, 'ScottSecure!', 4.90),
('Harper', 'Green', 'Seattle', 'WA', 'harper.green@gmail.com', NULL, 'Green42Secure!', 4.30),
('Charlotte', 'Carter', 'Boulder', 'CO', 'charlotte.carter@gmail.com', NULL, 'CarterSecure123!', 4.85),
('Logan', 'Nelson', 'Spokane', 'WA', 'logan.nelson@gmail.com', NULL, 'NelsonSecure1!', 4.60),
('Ella', 'Baker', 'Seattle', 'WA', 'ella.baker@gmail.com', NULL, 'BakerPass23!', 4.75),
('Daniel', 'Mitchell', 'Boulder', 'CO', 'daniel.mitchell@gmail.com', NULL, 'MitchellSecure42!', 4.95),
('Avery', 'Perez', 'Spokane', 'WA', 'avery.perez@gmail.com', NULL, 'PerezSecure!', 4.70),
('Mason', 'Roberts', 'Seattle', 'WA', 'mason.roberts@gmail.com', NULL, 'RobertsSecure123!', 4.65),
('Lily', 'Turner', 'Boulder', 'CO', 'lily.turner@gmail.com', NULL, 'TurnerSecure!', 4.75),
('Ethan', 'Phillips', 'Spokane', 'WA', 'ethan.phillips@gmail.com', NULL, 'PhillipsSecure42!', 4.90),
('Sophia', 'Evans', 'Seattle', 'WA', 'sophia.evans@gmail.com', NULL, 'EvansLife123!', 4.30);

-- Insert some categories into the ItemTypes table
INSERT INTO ItemTypes (type_name, description)
VALUES
('Furniture', 'Items related to home furniture such as chairs, tables, and couches.'),
('Textbooks', 'Books used in academic settings, typically for college courses.'),
('Electronics', 'Devices such as phones, laptops, cameras, and gadgets.'),
('Clothing', 'Items of apparel including shirts, pants, dresses, and jackets.'),
('Toys', 'Items intended for childrens play, including dolls, action figures, and games.'),
('Sports Equipment', 'Items used for sports or outdoor activities, like bikes, tennis rackets, and golf clubs.'),
('Books', 'Various types of books, including novels, non-fiction, and reference materials.'),
('Appliances', 'Items used in household tasks such as refrigerators, washing machines, and vacuums.'),
('Kitchenware', 'Items used in cooking and food preparation, such as pots, pans, and utensils.'),
('Art Supplies', 'Materials used for creating art, such as paints, brushes, and canvases.');

-- Insert some example items into ItemsForSale table
INSERT INTO ItemsForSale (item_type, item_description, price, seller_email, created_at, availability_status)
VALUES 
('Textbooks', 'Data Structures and Algorithms in Java', 60.00, 'michael.b@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Modern wooden dining table, seats six, excellent condition.', 250.00, 'john.doe@gmail.com', CURRENT_TIMESTAMP, TRUE),
('Textbooks', 'Introduction to Python programming, 2nd edition.', 40.00, 'jane.smith@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Used 4K monitor, 27-inch, great for gaming or work.', 300.00, 'emily.j@gmail.com', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Winter coat, barely used, size M.', 75.00, 'michael.b@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Sports Equipment', 'Tennis racket, lightweight, includes carrying case.', 120.00, 'sdavis@gonzaga.com', CURRENT_TIMESTAMP, TRUE),
('Books', 'Complete works of Shakespeare, hardcover edition.', 50.00, 'imay@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Appliances', 'Microwave oven, compact, like new.', 60.00, 'alice.green@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Office chair, ergonomic, fully adjustable.', 150.00, 'robert.clark@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Designer handbag, excellent condition.', 200.00, 'jessica.white@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Bluetooth speaker, portable, high bass.', 80.00, 'william.king@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'Advanced algorithms textbook, barely used.', 65.00, 'ella.adams@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Queen-size bed frame with headboard, solid wood.', 400.00, 'henry.baker@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Sports Equipment', 'Mountain bike, 21-speed, almost new.', 600.00, 'amelia.brown@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Textbooks', 'Statistics for Engineers and Scientists, 3rd edition.', 45.00, 'oliver.evans@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Appliances', 'Air fryer, 5L capacity, perfect condition.', 100.00, 'sophia.hill@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Noise-cancelling headphones, over-ear.', 150.00, 'james.harris@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'Art of War, annotated version.', 20.00, 'lily.kelly@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Bookshelf, 5-tier, sturdy.', 90.00, 'logan.reed@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Formal suit, navy blue, size L.', 180.00, 'emily.morgan@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Smartphone, 64GB, unlocked, excellent condition.', 400.00, 'daniel.diaz@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Outdoor patio set, table and four chairs.', 350.00, 'grace.long@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Sports Equipment', 'Set of golf clubs, lightly used.', 450.00, 'lucas.ross@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'Meditations by Marcus Aurelius, leather-bound.', 30.00, 'mia.sanders@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Appliances', 'Blender, high-performance, like new.', 120.00, 'jack.barnes@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Laptop, 15-inch, great for students.', 650.00, 'chloe.murphy@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Desk, modern design, with drawers.', 200.00, 'benjamin.cook@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Textbooks', 'Organic Chemistry, 4th edition, includes solutions manual.', 60.00, 'harper.gray@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Leather jacket, classic style, size M.', 300.00, 'elijah.wright@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'How to Win Friends and Influence People, hardcover.', 25.00, 'avery.hughes@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Gaming console, 1TB storage, excellent condition.', 400.00, 'charlotte.brooks@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Dining chairs, set of four, solid wood.', 250.00, 'henry.price@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Sports Equipment', 'Kayak, single-seater, includes paddle.', 500.00, 'ella.carter@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Textbooks', 'Linear Algebra Done Right, 3rd edition.', 35.00, 'alexander.turner@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Vintage dress, 1950s style, size S.', 150.00, 'isabella.parker@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'The Great Gatsby, collector’s edition.', 40.00, 'mason.collins@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Appliances', 'Coffee maker, programmable, 12-cup capacity.', 80.00, 'charlotte.simmons@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Sofa, three-seater, grey upholstery.', 700.00, 'oliver.bennett@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Tablet, 10-inch display, WiFi + Cellular.', 300.00, 'ava.wright@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Sports Equipment', 'Running shoes, barely used, size 10.', 100.00, 'henry.green@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'Becoming by Michelle Obama, hardcover.', 25.00, 'mia.ward@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Coffee table, glass top, minimalist design.', 200.00, 'logan.foster@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Rain jacket, waterproof, size XL.', 70.00, 'emily.james@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Gently used laptop with 16GB RAM and 512GB SSD.', 650.00, 'john.doe@gmail.com', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Comfortable 3-seater sofa, lightly used.', 250.00, 'jane.smith@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Brand new winter jacket, size M.', 85.00, 'emily.j@gmail.com', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Noise-cancelling headphones in excellent condition.', 120.00, 'sdavis@gonzaga.com', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Dining table with 4 chairs, made of solid wood.', 400.00, 'imay@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Designer handbag, barely used.', 300.00, 'alice.green@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'Introduction to Data Science textbook, 3rd edition.', 60.00, 'robert.clark@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Smartphone, unlocked, 128GB storage.', 350.00, 'jessica.white@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Office chair with lumbar support.', 120.00, 'william.king@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Pair of running shoes, size 9, lightly worn.', 50.00, 'ella.adams@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'Complete set of Harry Potter novels.', 75.00, 'henry.baker@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Gaming console with two controllers.', 300.00, 'amelia.brown@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Bookshelf with 5 adjustable shelves.', 100.00, 'oliver.evans@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Formal suit, size 42R.', 180.00, 'sophia.hill@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'Advanced Algorithms textbook, like new.', 90.00, 'james.harris@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Digital camera with 24MP resolution.', 220.00, 'lily.kelly@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Set of 2 nightstands, modern design.', 150.00, 'logan.reed@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Designer scarf, 100% silk.', 70.00, 'emily.morgan@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'Historical fiction book collection.', 65.00, 'daniel.diaz@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Used monitor, 27-inch, Full HD.', 180.00, 'grace.long@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'King-size bed frame, no mattress.', 300.00, 'lucas.ross@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Vintage leather jacket, size L.', 150.00, 'mia.sanders@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'Introduction to Machine Learning book.', 55.00, 'jack.barnes@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Bluetooth speaker, waterproof.', 45.00, 'chloe.murphy@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Outdoor patio set, includes table and 4 chairs.', 500.00, 'benjamin.cook@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Evening dress, size 6.', 120.00, 'harper.gray@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'Cookbook with 100+ healthy recipes.', 35.00, 'elijah.wright@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Smartwatch, fitness edition.', 150.00, 'avery.hughes@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Bean bag chair, XL size.', 90.00, 'charlotte.brooks@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Men’s hiking boots, size 11.', 85.00, 'henry.price@gonzaga.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'Programming in Python, 5th Edition.', 65.00, 'ella.carter@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'External hard drive, 2TB.', 75.00, 'alexander.turner@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Futon bed, black metal frame.', 200.00, 'isabella.parker@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Designer sunglasses, polarized.', 120.00, 'mason.collins@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'English Literature anthology.', 50.00, 'charlotte.simmons@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Electronics', 'Used tablet, 10-inch screen, 64GB.', 180.00, 'oliver.bennett@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Furniture', 'Corner desk with hutch.', 250.00, 'ava.wright@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Clothing', 'Women’s workout leggings, size S.', 40.00, 'henry.green@colorado.edu', CURRENT_TIMESTAMP, TRUE),
('Books', 'Photography for Beginners guide.', 30.00, 'mia.ward@colorado.edu', CURRENT_TIMESTAMP, TRUE);

INSERT INTO Skills (skill_type, description)
VALUES
('Web Development', 'Building websites and web applications using HTML, CSS, JavaScript, and frameworks like React or Angular.'),
('Data Analysis', 'Interpreting and visualizing data using tools like Excel, Python, R, or Tableau.'),('Public Speaking', 'Delivering presentations confidently and effectively in front of an audience.'),
('Programming', 'Writing and debugging code in languages like Python, Java, or C++.'),
('Graphic Design', 'Creating visual content using tools like Adobe Photoshop, Illustrator, or Canva.'),('Problem Solving', 'Analyzing issues and coming up with innovative solutions.'),
('Project Management', 'Planning, organizing, and overseeing projects to completion.'),('Writing', 'Drafting essays, reports, and other written content with clarity and purpose.'),
('Critical Thinking', 'Evaluating information and arguments to make logical decisions.'),
('Networking', 'Building and maintaining professional relationships for career growth.'),
('Research', 'Gathering and analyzing information to gain insights and support conclusions.'),
('Event Planning', 'Organizing and coordinating events, including logistics and scheduling.'),
('Marketing', 'Promoting products, services, or ideas using digital and traditional channels.'),
('Social Media Management', 'Managing and growing online presence on platforms like Instagram, Twitter, and LinkedIn.'),
('Foreign Language', 'Speaking and understanding a language other than your native language.'),
('Technical Writing', 'Writing documentation, manuals, or guides for technical processes.'),
('Coding', 'Developing software or applications using programming languages.'),
('User Experience Design', 'Improving user satisfaction with products through design and usability improvements.'),
('Cybersecurity', 'Protecting systems, networks, and data from digital attacks.'),
('Machine Learning', 'Developing algorithms that allow computers to learn and make predictions.'),('Video Editing', 'Editing and producing video content using software like Adobe Premiere Pro or Final Cut Pro.'),
('3D Modeling', 'Creating 3D digital representations using tools like Blender or Autodesk Maya.'),
('Tutoring', 'Assisting peers or students in understanding various subjects such as math, science, or literature.'), 
('Babysitting', 'Providing childcare and supervision, ensuring the safety and well-being of children.'),
('Lawn Mowing', 'Maintaining lawns by cutting grass, trimming edges, and cleaning up clippings.'),
('Pet Sitting', 'Taking care of pets while their owners are away, including feeding, walking, and providing companionship.'),
('House Cleaning', 'Performing various cleaning tasks in homes such as dusting, vacuuming, and organizing.'),
('Errand Running', 'Completing tasks such as grocery shopping, picking up dry cleaning, or delivering packages.'),
('Car Washing', 'Washing and detailing vehicles to maintain cleanliness and appearance.'),
('Snow Removal', 'Clearing snow from driveways, sidewalks, and walkways to maintain safety and accessibility.'),
('Photography', 'Taking pictures of families, couples, nature, etc.'),
('Accounting', 'Creating budgets, and working with numbers for companies, individuals, and projects.');

INSERT INTO FreelanceWork (skill_type, description, payment, posted_by)
VALUES
('Web Development', 'Building websites and web applications using HTML, CSS, JavaScript, and frameworks like React or Angular.', 40.00, 'jane.smith@gonzaga.edu'),
('Data Analysis', 'Interpreting and visualizing data using tools like Excel, Python, R, or Tableau.', 45.00, 'avery.hughes@gonzaga.edu'),
('Public Speaking', 'Delivering presentations confidently and effectively in front of an audience.', 30.00, 'elijah.wright@gonzaga.edu'),
('Programming', 'Writing and debugging code in languages like Python, Java, or C++.', 40.00, 'henry.baker@gonzaga.edu'),
('Graphic Design', 'Creating visual content using tools like Adobe Photoshop, Illustrator, or Canva.', 45.00, 'alice.green@gonzaga.edu'),
('Problem Solving', 'Analyzing issues and coming up with innovative solutions.', 30.00, 'mia.sanders@gonzaga.edu'),
('Project Management', 'Planning, organizing, and overseeing projects to completion.', 50.00, 'ella.carter@colorado.edu'),
('Writing', 'Drafting essays, reports, and other written content with clarity and purpose.', 22.00, 'william.king@gonzaga.edu'),
('Critical Thinking', 'Evaluating information and arguments to make logical decisions.', 25.00, 'chloe.murphy@gonzaga.edu'),
('Networking', 'Building and maintaining professional relationships for career growth.', 30.00, 'lucas.ross@gonzaga.edu'),
('Research', 'Gathering and analyzing information to gain insights and support conclusions.', 30.00, 'mia.sanders@gonzaga.edu'),
('Event Planning', 'Organizing and coordinating events, including logistics and scheduling.', 35.00, 'imay@gonzaga.edu'),
('Marketing', 'Promoting products, services, or ideas using digital and traditional channels.', 25.00, 'emily.j@gmail.com'),
('Social Media Management', 'Managing and growing online presence on platforms like Instagram, Twitter, and LinkedIn.', 28.00, 'emily.morgan@gonzaga.edu'),
('Foreign Language', 'Speaking and understanding a language other than your native language.', 20.00, 'logan.reed@gonzaga.edu'),
('Technical Writing', 'Writing documentation, manuals, or guides for technical processes.', 30.00, 'sophia.hill@gonzaga.edu'),
('Coding', 'Developing software or applications using programming languages.', 40.00, 'henry.baker@gonzaga.edu'),
('User Experience Design', 'Improving user satisfaction with products through design and usability improvements.', 45.00, 'amelia.brown@gonzaga.edu'),
('Cybersecurity', 'Protecting systems, networks, and data from digital attacks.', 50.00, 'lucas.ross@gonzaga.edu'),
('Machine Learning', 'Developing algorithms that allow computers to learn and make predictions.', 60.00, 'elijah.wright@gonzaga.edu'),
('Video Editing', 'Editing and producing video content using software like Adobe Premiere Pro or Final Cut Pro.', 40.00, 'daniel.diaz@gonzaga.edu'),
('3D Modeling', 'Creating 3D digital representations using tools like Blender or Autodesk Maya.', 50.00, 'charlotte.brooks@gonzaga.edu'),
('Tutoring', 'Assisting peers or students in understanding various subjects such as math, science, or literature.', 30.00, 'michael.b@gonzaga.edu'),
('Babysitting', 'Providing childcare and supervision, ensuring the safety and well-being of children.', 15.00, 'john.doe@gmail.com'),
('Lawn Mowing', 'Maintaining lawns by cutting grass, trimming edges, and cleaning up clippings.', 18.00, 'oliver.evans@gonzaga.edu'),
('Pet Sitting', 'Taking care of pets while their owners are away, including feeding, walking, and providing companionship.', 20.00, 'logan.reed@gonzaga.edu'),
('House Cleaning', 'Performing various cleaning tasks in homes such as dusting, vacuuming, and organizing.', 18.00, 'jack.barnes@gonzaga.edu'),
('Errand Running', 'Completing tasks such as grocery shopping, picking up dry cleaning, or delivering packages.', 20.00, 'james.harris@gonzaga.edu'),
('Car Washing', 'Washing and detailing vehicles to maintain cleanliness and appearance.', 25.00, 'benjamin.cook@gonzaga.edu'),
('Snow Removal', 'Clearing snow from driveways, sidewalks, and walkways to maintain safety and accessibility.', 25.00, 'grace.long@gonzaga.edu'),
('Photography', 'Taking pictures of families, couples, nature, etc.', 40.00, 'henry.price@gonzaga.edu'),
('Web Development', 'Build a responsive website for a local business.', 35.00, 'john.doe@gmail.com'),
('Graphic Design', 'Design a logo for a startup.', 25.00, 'jane.smith@gonzaga.edu'),
('Tutoring', 'Help a student improve their math skills.', 18.00, 'sdavis@gonzaga.com'),
('Photography', 'Capture professional headshots.', 50.00, 'imay@gonzaga.edu'),
('Video Editing', 'Edit footage for a promotional video.', 40.00, 'alice.green@gonzaga.edu'),
('Data Analysis', 'Analyze sales data and provide insights.', 35.00, 'ella.adams@gonzaga.edu'),
('3D Modeling', 'Create 3D models for a game development project.', 45.00, 'oliver.evans@gonzaga.edu'),
('Foreign Language', 'Translate documents from Spanish to English.', 25.00, 'sophia.hill@gonzaga.edu'),
('Social Media Management', 'Manage Instagram and TikTok accounts for a brand.', 30.00, 'james.harris@gonzaga.edu'),
('Event Planning', 'Plan and coordinate a community event.', 35.00, 'emily.morgan@gonzaga.edu'),
('Accounting', 'Assist with preparing small business tax returns.', 38.00, 'lucas.ross@gonzaga.edu');

-- Generate 45 random transactions using the price from ItemsForSale
INSERT INTO ItemTransactions (item_id, buyer_email, seller_email, amount_paid, date_completed)
SELECT
    random_transactions.item_id,
    random_transactions.buyer_email,
    random_transactions.seller_email,
    random_transactions.price AS amount_paid, -- Use price from ItemsForSale
    NOW() -- Use current time for simplicity
FROM (
    SELECT
        i.item_id,
        u1.email AS buyer_email,
        u2.email AS seller_email,
        i.price
    FROM
        ItemsForSale i
    CROSS JOIN
        Users u1 -- Join to allow any user to be a potential buyer
    INNER JOIN
        Users u2 ON u2.email = i.seller_email -- Ensure seller matches item
    WHERE
        u1.email != u2.email -- Ensure buyer is not the seller
    ORDER BY
        RANDOM() -- Shuffle rows to add randomness
    LIMIT 45 -- Limit to 45 transactions
) AS random_transactions;

-- Populate FreelanceTransactions with 45 random entries
INSERT INTO FreelanceTransactions (job_id, buyer_email, worker_email, amount_paid, date_completed)
SELECT
    random_jobs.job_id,
    random_jobs.buyer_email,
    random_jobs.worker_email,
    random_jobs.payment AS amount_paid, -- Use payment from FreelanceWork
    NOW() AS date_completed -- Random date within the last year
FROM (
    SELECT
        fw.job_id,
        u1.email AS buyer_email, -- Random buyer
        u2.email AS worker_email, -- Worker assigned to the job
        fw.payment
    FROM
        FreelanceWork fw
    CROSS JOIN
        Users u1 -- Allow any user to be a buyer
    INNER JOIN
        Users u2 ON u2.email = fw.posted_by -- Ensure worker matches the job poster
    WHERE
        u1.email != u2.email -- Ensure buyer and worker are not the same person
    ORDER BY
        RANDOM() -- Shuffle rows to add randomness
    LIMIT 45 -- Limit to 100 transactions
) AS random_jobs;

-- Populate ItemRatings based on completed ItemTransactions
INSERT INTO ItemRatings (item_id, rater_email, rating_email, rating, review, created_at)
SELECT DISTINCT
    it.item_id,
    it.buyer_email AS rater_email, -- Buyer giving the rating
    it.seller_email AS rating_email, -- Seller being rated
    ROUND((4 + RANDOM())::NUMERIC, 2) AS rating, -- Generate a random rating between 4.00 and 5.00
    CASE
        WHEN RANDOM() < 0.5 THEN NULL -- 50% chance of no review
        ELSE 'Great transaction! Would recommend.'
    END AS review,
    it.date_completed + INTERVAL '1 day' -- Rating submitted a day after transaction
FROM
    ItemTransactions it
ON CONFLICT DO NOTHING;

-- Populate FreelanceWorkRatings based on completed FreelanceTransactions
INSERT INTO FreelanceWorkRatings (freelance_job_id, rater_email, rating_email, rating, review, created_at)
SELECT DISTINCT
    ft.job_id,
    ft.buyer_email AS rater_email, -- Buyer (client) giving the rating
    ft.worker_email AS rating_email, -- Freelancer being rated
    ROUND((4 + RANDOM())::NUMERIC, 2) AS rating, -- Generate a random rating between 4.00 and 5.00
    CASE
        WHEN RANDOM() < 0.7 THEN 'Great job! Would hire again.' -- 70% chance of review
        ELSE NULL
    END AS review,
    ft.date_completed + INTERVAL '2 days' -- Rating submitted two days after transaction
FROM
    FreelanceTransactions ft;

-- Insert message instances for a conversation related to purchasing items or freelance work
INSERT INTO Messages (sender_email, recipient_email, message_content, is_read)
VALUES
-- Conversation 1 Jane Smith buyer and Sarah Davis seller about an item for sale
('jane.smith@gonzaga.edu', 'sdavis@gonzaga.com', 'Hi Sarah I saw your item listed for sale. Is it still available?', FALSE),
('sdavis@gonzaga.com', 'jane.smith@gonzaga.edu', 'Yes its still available. Would you like to purchase it?', FALSE),
('jane.smith@gonzaga.edu', 'sdavis@gonzaga.com', 'Great. How much are you asking for?', FALSE),
('sdavis@gonzaga.com', 'jane.smith@gonzaga.edu', 'Im asking for 50, let me know if that works for you', FALSE),
('jane.smith@gonzaga.edu', 'sdavis@gonzaga.com', 'That works for me. Ill take it. How do I pay?', TRUE),
('sdavis@gonzaga.com', 'jane.smith@gonzaga.edu', 'You can pay via Venmo or PayPal. Let me know which one you prefer', TRUE),

-- Conversation 2 Izzy May client and William King freelancer about a freelance job
('imay@gonzaga.edu', 'william.king@gonzaga.edu', 'Hi William, I need someone to help with a website redesign project. Are you available', FALSE),
('william.king@gonzaga.edu', 'imay@gonzaga.edu', 'Hi Izzy., Im available. Could you tell me more about the project?', FALSE),
('imay@gonzaga.edu', 'william.king@gonzaga.edu', 'I need help updating the design and making it mobile friendly. Do you have experience with responsive design?', FALSE),
('william.king@gonzaga.edu', 'imay@gonzaga.edu', 'Yes, I have experience with responsive design and would love to help with your project!', FALSE),
('imay@gonzaga.edu', 'william.king@gonzaga.edu', 'That sounds great. What would your rate be for the project?', FALSE),
('william.king@gonzaga.edu', 'imay@gonzaga.edu', 'I charge 40 per hour for web design projects. Let me know if that works for you.', TRUE),
('imay@gonzaga.edu', 'william.king@gonzaga.edu', 'That works for me. Lets set up a meeting to discuss the details', TRUE),

-- Conversation 3 Alice Green buyer and Robert Clark seller about an item for sale
('alice.green@gonzaga.edu', 'robert.clark@gonzaga.edu', 'Hi Robert Im interested in the item you listed for sale Can you tell me more about its condition', FALSE),
('robert.clark@gonzaga.edu', 'alice.green@gonzaga.edu', 'Hi Alice the item is in great condition barely used Would you like to come see it', FALSE),
('alice.green@gonzaga.edu', 'robert.clark@gonzaga.edu', 'I would love to When are you available to meet', FALSE),
('robert.clark@gonzaga.edu', 'alice.green@gonzaga.edu', 'Im free this Saturday afternoon Does that work for you', TRUE),
('alice.green@gonzaga.edu', 'robert.clark@gonzaga.edu', 'Saturday works perfectly Ill see you then', TRUE),

-- Conversation 4 Jessica White client and Amelia White freelancer about freelance work
('jessica.white@gonzaga.edu', 'amelia.white@gmail.com', 'Hi Amelia I saw your freelance profile and wanted to know if youre available for a social media marketing project', FALSE),
('amelia.white@gmail.com', 'jessica.white@gonzaga.edu', 'Hi Jessica I am available What kind of social media marketing are you looking for', FALSE),
('jessica.white@gonzaga.edu', 'amelia.white@gmail.com', 'I need help with content creation and scheduling posts for my brand Do you have experience with that', FALSE),
('amelia.white@gmail.com', 'jessica.white@gonzaga.edu', 'Yes I have experience with content creation and scheduling I can help you with your brand', FALSE),
('jessica.white@gonzaga.edu', 'amelia.white@gmail.com', 'What is your rate for social media marketing services', TRUE),
('amelia.white@gmail.com', 'jessica.white@gonzaga.edu', 'I charge 35 per hour for social media marketing Let me know if that works for you', TRUE),
('jessica.white@gonzaga.edu', 'amelia.white@gmail.com', 'That sounds good Lets set up a call to discuss the details', TRUE),

-- Conversation 5 Olivia Taylor buyer and Henry Baker seller about an item for sale
('olivia.taylor@gmail.com', 'henry.baker@gonzaga.edu', 'Hi Henry Im interested in the item you have for sale Can you send me more details', FALSE),
('henry.baker@gonzaga.edu', 'olivia.taylor@gmail.com', 'Hi Olivia sure Its a brand new item only used once Would you like to see pictures', FALSE),
('olivia.taylor@gmail.com', 'henry.baker@gonzaga.edu', 'Yes that would be great I want to make sure its what Im looking for', FALSE),
('henry.baker@gonzaga.edu', 'olivia.taylor@gmail.com', 'I can send pictures over email Would you prefer PayPal for payment', TRUE),
('olivia.taylor@gmail.com', 'henry.baker@gonzaga.edu', 'Yes PayPal works for me Ill wait for the pictures', TRUE),

-- Conversation 6 Jessica White buyer and Robert Clark seller about an item for sale
('jessica.white@gonzaga.edu', 'robert.clark@gonzaga.edu', 'Hi Robert I saw your item for sale Is it still available', FALSE),
('robert.clark@gonzaga.edu', 'jessica.white@gonzaga.edu', 'Yes its available What is your offer', FALSE),
('jessica.white@gonzaga.edu', 'robert.clark@gonzaga.edu', 'I can offer 40 for it Is that acceptable', FALSE),
('robert.clark@gonzaga.edu', 'jessica.white@gonzaga.edu', '40 works for me Let me know how you want to pay', TRUE),
('jessica.white@gonzaga.edu', 'robert.clark@gonzaga.edu', 'I can pay via Venmo Does that work for you', TRUE),
('robert.clark@gonzaga.edu', 'jessica.white@gonzaga.edu', 'Venmo is fine Ill send you the details', TRUE),

-- Conversation 7 Alice Green buyer and Liam Lewis seller about an item for sale
('alice.green@gonzaga.edu', 'liam.lewis@gmail.com', 'Hey Liam I am interested in the item you listed Can you send me more details', FALSE),
('liam.lewis@gmail.com', 'alice.green@gonzaga.edu', 'Sure Alice Its in great condition What more would you like to know', FALSE),
('alice.green@gonzaga.edu', 'liam.lewis@gmail.com', 'Can you tell me if it comes with the original packaging', FALSE),
('liam.lewis@gmail.com', 'alice.green@gonzaga.edu', 'Yes it does The item is complete with packaging and accessories', TRUE),
('alice.green@gonzaga.edu', 'liam.lewis@gmail.com', 'That sounds great I want to buy it How should I pay', TRUE),
('liam.lewis@gmail.com', 'alice.green@gonzaga.edu', 'You can pay via PayPal or CashApp Let me know which one works best for you', TRUE),

-- Conversation 8 Izzy May client and William King freelancer about a freelance job
('imay@gonzaga.edu', 'william.king@gonzaga.edu', 'Hi William I need help with some graphic design work for my website Are you available', FALSE),
('william.king@gonzaga.edu', 'imay@gonzaga.edu', 'Hi Izzy Yes I am available What do you need done', FALSE),
('imay@gonzaga.edu', 'william.king@gonzaga.edu', 'I need help with creating logos and banners for my site Do you have experience with that', FALSE),
('william.king@gonzaga.edu', 'imay@gonzaga.edu', 'Yes I have experience with both logos and banners Let me know what your vision is', FALSE),
('imay@gonzaga.edu', 'william.king@gonzaga.edu', 'Great My budget is 500 for the whole project Would you be willing to do it for that amount', TRUE),
('william.king@gonzaga.edu', 'imay@gonzaga.edu', '500 works for me Ill start working on it as soon as possible', TRUE),

-- Conversation 9 Olivia Taylor buyer and Sarah Davis seller about an item for sale
('olivia.taylor@gmail.com', 'sdavis@gonzaga.com', 'Hi Sarah I saw your item listed for sale Is it still available', FALSE),
('sdavis@gonzaga.com', 'olivia.taylor@gmail.com', 'Yes it is Would you like to purchase it', FALSE),
('olivia.taylor@gmail.com', 'sdavis@gonzaga.com', 'Yes Im interested How much are you asking for it', FALSE),
('sdavis@gonzaga.com', 'olivia.taylor@gmail.com', 'I am asking 60 for it Let me know if that works for you', FALSE),
('olivia.taylor@gmail.com', 'sdavis@gonzaga.com', '60 sounds good to me I will take it What payment methods do you accept', TRUE),
('sdavis@gonzaga.com', 'olivia.taylor@gmail.com', 'I accept PayPal or Venmo Let me know which one you prefer', TRUE),

-- Conversation 10 Amelia White client and Jessica White freelancer about a freelance job
('amelia.white@gmail.com', 'jessica.white@gonzaga.edu', 'Hi Jessica I saw your profile and wanted to know if you can help with content writing for my blog', FALSE),
('jessica.white@gonzaga.edu', 'amelia.white@gmail.com', 'Hi Amelia Yes I can help with content writing What kind of topics are you interested in', FALSE),
('amelia.white@gmail.com', 'jessica.white@gonzaga.edu', 'Im focusing on travel and lifestyle Would you be comfortable writing in those areas', FALSE),
('jessica.white@gonzaga.edu', 'amelia.white@gmail.com', 'Yes I have experience in those areas and would love to help with your blog', FALSE),
('amelia.white@gmail.com', 'jessica.white@gonzaga.edu', 'What are your rates for writing blog posts', TRUE),
('jessica.white@gonzaga.edu', 'amelia.white@gmail.com', 'I charge 30 per post Let me know if that works for you', TRUE),

-- Conversation 11 Robert Clark buyer and William King seller about an item for sale
('robert.clark@gonzaga.edu', 'william.king@gonzaga.edu', 'Hey William I am interested in the item you have for sale Is it still available', FALSE),
('william.king@gonzaga.edu', 'robert.clark@gonzaga.edu', 'Yes its available What is your offer', FALSE),
('robert.clark@gonzaga.edu', 'william.king@gonzaga.edu', 'I can offer 45 Does that work for you', FALSE),
('william.king@gonzaga.edu', 'robert.clark@gonzaga.edu', '45 is fine Let me know how you want to pay', TRUE),
('robert.clark@gonzaga.edu', 'william.king@gonzaga.edu', 'I can pay via Venmo Will that work', TRUE),
('william.king@gonzaga.edu', 'robert.clark@gonzaga.edu', 'Venmo is good Ill send the details', TRUE),

-- Conversation 12 Izzy May client and Liam Lewis freelancer about a freelance job
('imay@gonzaga.edu', 'liam.lewis@gmail.com', 'Hi Liam I need a freelance writer for some blog posts Are you available', FALSE),
('liam.lewis@gmail.com', 'imay@gonzaga.edu', 'Hi Izzy Yes I am available What type of blog posts do you need', FALSE),
('imay@gonzaga.edu', 'liam.lewis@gmail.com', 'I need posts on technology and gadgets Would you be comfortable writing about those topics', FALSE),
('liam.lewis@gmail.com', 'imay@gonzaga.edu', 'Yes I have experience writing on those topics Id love to help', FALSE),
('imay@gonzaga.edu', 'liam.lewis@gmail.com', 'Great What is your rate for blog posts', TRUE),
('liam.lewis@gmail.com', 'imay@gonzaga.edu', 'I charge 25 per blog post Let me know if that works for you', TRUE),

-- Conversation 13 Sarah Davis buyer and Henry Baker seller about an item for sale
('sdavis@gonzaga.com', 'henry.baker@gonzaga.edu', 'Hi Henry I saw your item for sale Is it still available', FALSE),
('henry.baker@gonzaga.edu', 'sdavis@gonzaga.com', 'Yes its available What is your offer', FALSE),
('sdavis@gonzaga.com', 'henry.baker@gonzaga.edu', 'I can offer 50 for it Is that okay', FALSE),
('henry.baker@gonzaga.edu', 'sdavis@gonzaga.com', '50 is fine Let me know how you would like to pay', TRUE),
('sdavis@gonzaga.com', 'henry.baker@gonzaga.edu', 'I can pay via PayPal Is that acceptable', TRUE),
('henry.baker@gonzaga.edu', 'sdavis@gonzaga.com', 'PayPal works for me Ill send you my details', TRUE),

-- Conversation 14 Olivia Taylor client and Alice Green freelancer about a freelance job
('olivia.taylor@gmail.com', 'alice.green@gonzaga.edu', 'Hi Alice I need a graphic designer for some marketing materials Are you available', FALSE),
('alice.green@gonzaga.edu', 'olivia.taylor@gmail.com', 'Hi Olivia Yes I am available What kind of marketing materials do you need', FALSE),
('olivia.taylor@gmail.com', 'alice.green@gonzaga.edu', 'I need posters and flyers for an event Im organizing. Can you help with that?', FALSE),
('alice.green@gonzaga.edu', 'olivia.taylor@gmail.com', 'Yes I can design posters and flyers What is your budget', FALSE),
('olivia.taylor@gmail.com', 'alice.green@gonzaga.edu', 'My budget is 300 for the project Does that work', TRUE),
('alice.green@gonzaga.edu', 'olivia.taylor@gmail.com', '300 works for me Lets get started', TRUE),

-- Conversation 15 Jessica White buyer and Olivia Taylor seller about an item for sale
('jessica.white@gonzaga.edu', 'olivia.taylor@gmail.com', 'Hi Olivia I saw your item for sale Is it still available', FALSE),
('olivia.taylor@gmail.com', 'jessica.white@gonzaga.edu', 'Yes it is Would you like to buy it', FALSE),
('jessica.white@gonzaga.edu', 'olivia.taylor@gmail.com', 'Yes Im interested How much are you asking for it', FALSE),
('olivia.taylor@gmail.com', 'jessica.white@gonzaga.edu', 'I am asking 70 for it Let me know if that works for you', FALSE),
('jessica.white@gonzaga.edu', 'olivia.taylor@gmail.com', '70 works for me Ill take it What payment methods do you accept', TRUE),
('olivia.taylor@gmail.com', 'jessica.white@gonzaga.edu', 'I accept PayPal or Venmo Let me know which one you prefer', TRUE);
