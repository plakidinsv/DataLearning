DROP TABLE IF EXISTS dim_products; 
CREATE TABLE IF NOT EXISTS dim_products(
    id INT,
    name VARCHAR,
    groupname VARCHAR,
    modify_date date
    );