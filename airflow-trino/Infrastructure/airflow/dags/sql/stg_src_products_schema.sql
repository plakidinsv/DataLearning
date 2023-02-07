DROP TABLE IF EXISTS src_dim_products; 
CREATE TABLE IF NOT EXISTS src_dim_products(
    id INT,
    name VARCHAR,
    groupname VARCHAR,
    modify_date date
    );