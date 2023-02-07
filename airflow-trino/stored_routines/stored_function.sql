CREATE OR REPLACE FUNCTION most_popular_product() 
RETURNS text 
AS $$
DECLARE top_product text;
BEGIN
        WITH popular_products AS (
            SELECT product_id, SUM(qty) as total_quantity
            FROM fact_sales
            GROUP BY product_id
            ORDER BY SUM(qty) DESC
            LIMIT 1
        )
        SELECT name
        INTO top_product 
        FROM popular_products
        JOIN dim_products ON dim_products.id = popular_products.product_id;
    RETURN top_product;
END; 
$$ LANGUAGE plpgsql;