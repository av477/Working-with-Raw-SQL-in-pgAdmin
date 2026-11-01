-- Create a one-to-many relationship: one user can have multiple calculations.
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS calculations (
    id SERIAL PRIMARY KEY,
    operation VARCHAR(20) NOT NULL,
    operand_a FLOAT NOT NULL,
    operand_b FLOAT NOT NULL,
    result FLOAT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Seed users; skip existing usernames so this script can be run again.
INSERT INTO users (username, email)
VALUES
    ('alice', 'alice@example.com'),
    ('bob', 'bob@example.com')
ON CONFLICT (username) DO NOTHING;

-- Associate each example calculation with its user without assuming generated IDs.
INSERT INTO calculations (operation, operand_a, operand_b, result, user_id)
SELECT seed.operation, seed.operand_a, seed.operand_b, seed.result, users.id
FROM (
    VALUES
        ('alice', 'add', 2.0, 3.0, 5.0),
        ('alice', 'divide', 10.0, 2.0, 5.0),
        ('bob', 'multiply', 4.0, 5.0, 20.0)
) AS seed(username, operation, operand_a, operand_b, result)
JOIN users ON users.username = seed.username
WHERE NOT EXISTS (
    SELECT 1
    FROM calculations
    WHERE calculations.user_id = users.id
      AND calculations.operation = seed.operation
      AND calculations.operand_a = seed.operand_a
      AND calculations.operand_b = seed.operand_b
);

-- Retrieve all users.
SELECT * FROM users;

-- Retrieve all calculations.
SELECT * FROM calculations;

-- Join calculations to their users.
SELECT users.username, calculations.operation,
       calculations.operand_a, calculations.operand_b, calculations.result
FROM calculations
JOIN users ON calculations.user_id = users.id;

-- Update Alice's addition example.
UPDATE calculations
SET result = 6
WHERE operation = 'add'
  AND operand_a = 2
  AND operand_b = 3
  AND user_id = (SELECT id FROM users WHERE username = 'alice');

-- Delete Alice's division example.
DELETE FROM calculations
WHERE operation = 'divide'
  AND operand_a = 10
  AND operand_b = 2
  AND user_id = (SELECT id FROM users WHERE username = 'alice');

-- Show the remaining calculations after the update and delete.
SELECT users.username, calculations.operation,
       calculations.operand_a, calculations.operand_b, calculations.result
FROM calculations
JOIN users ON calculations.user_id = users.id;
