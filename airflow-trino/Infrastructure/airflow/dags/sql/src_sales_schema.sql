DROP TABLE IF EXISTS sales; 
CREATE TABLE IF NOT EXISTS sales(
    customer_id INT,
    product_id INT,
    qty INT,
    modify_date date
    );