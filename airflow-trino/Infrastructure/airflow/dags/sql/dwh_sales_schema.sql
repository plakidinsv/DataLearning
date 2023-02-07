DROP TABLE IF EXISTS fact_sales; 
CREATE TABLE IF NOT EXISTS fact_sales(
    customer_id INT,
    product_id INT,
    qty INT
    );