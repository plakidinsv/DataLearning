DROP TABLE IF EXISTS src_dim_customers; 
CREATE TABLE IF NOT EXISTS src_dim_customers(
    id INT,
    name VARCHAR,
    country VARCHAR,
    modify_date date
    );