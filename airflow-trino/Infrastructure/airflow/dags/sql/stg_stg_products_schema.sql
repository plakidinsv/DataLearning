DROP TABLE IF EXISTS stg_dim_products; 
CREATE TABLE IF NOT EXISTS stg_dim_products(
    id INT,
    name VARCHAR,
    groupname VARCHAR
    );