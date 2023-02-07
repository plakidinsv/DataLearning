DROP TABLE IF EXISTS high_watermark; 
CREATE TABLE IF NOT EXISTS high_watermark(
    name_table VARCHAR,
    watermark_value date
    );