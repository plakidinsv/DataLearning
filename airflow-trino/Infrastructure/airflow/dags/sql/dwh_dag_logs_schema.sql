DROP TABLE IF EXISTS dag_logs; 
CREATE TABLE IF NOT EXISTS dag_logs(
    dag_id VARCHAR,
    task_id VARCHAR,
    run_time TIMESTAMP,
    error_message VARCHAR
    );