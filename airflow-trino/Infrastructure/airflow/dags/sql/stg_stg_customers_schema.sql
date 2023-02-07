DROP TABLE IF EXISTS stg_dim_customers; 
CREATE TABLE IF NOT EXISTS stg_dim_customers(
    id INT,
    name VARCHAR,
    country VARCHAR
    );