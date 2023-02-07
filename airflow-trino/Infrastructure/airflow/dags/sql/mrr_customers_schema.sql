DROP TABLE IF EXISTS dim_customers; 
CREATE TABLE IF NOT EXISTS dim_customers(
    id INT,
    name VARCHAR,
    country VARCHAR,
    modify_date date
    );