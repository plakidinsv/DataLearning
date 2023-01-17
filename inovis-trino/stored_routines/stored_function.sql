CREATE OR REPLACE FUNCTION most_popular_product() RETURNS text AS 
$BODY$
BEGIN
    RETURN (
        WITH popular_products AS (
            SELECT product_id, SUM(quantity) as total_quantity
            FROM fact_sales
            GROUP BY product_id
            ORDER BY total_quantity DESC
            LIMIT 1
        )
        SELECT name
        FROM popular_products
        JOIN products ON products.id = popular_products.product_id
    );
END; 
$BODY$
LANGUAGE plpgsql ;
