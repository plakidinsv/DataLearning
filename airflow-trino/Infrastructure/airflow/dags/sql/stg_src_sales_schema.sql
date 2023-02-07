DROP TABLE IF EXISTS src_fact_sales; 
CREATE TABLE IF NOT EXISTS src_fact_sales(
    customer_id INT,
    product_id INT,
    qty INT,
    modify_date date
    );