DROP TABLE IF EXISTS stg_high_watermark; 
CREATE TABLE IF NOT EXISTS stg_high_watermark(
    name_table VARCHAR,
    watermark_value date
    );