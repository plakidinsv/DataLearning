DROP TABLE IF EXISTS procedure_errors; 
CREATE TABLE IF NOT EXISTS procedure_errors(
    name VARCHAR,
    execution_time TIMESTAMP,
    error_message VARCHAR
    );