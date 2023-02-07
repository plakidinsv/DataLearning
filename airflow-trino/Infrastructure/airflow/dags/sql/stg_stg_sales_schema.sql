DROP TABLE IF EXISTS stg_fact_sales; 
CREATE TABLE IF NOT EXISTS stg_fact_sales(
    customer_id INT,
    product_id INT,
    qty INT
    );