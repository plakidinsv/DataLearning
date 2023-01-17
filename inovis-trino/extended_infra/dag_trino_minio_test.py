from airflow import DAG
from datetime import datetime, timedelta
from airflow.providers.trino.operators.trino import TrinoOperator

# Define default_args dict to pass to the DAG's constructor
default_args = {
    'owner': 'plsv',
    'start_date': datetime(2023, 1, 1),
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1)
}

# Create a DAG instance
with DAG (dag_id='trino_minio_test',
        default_args=default_args,          
        schedule_interval=None,
        catchup=False,
        tags=['test'],
) as dag:
    
    trino_minio_schema = TrinoOperator(
        task_id="trino_create_schema_minio",
        trino_conn_id='trino_conn',
        sql=f"""create schema if not exists minio.trino
            with (location='s3a://trino/')""",
        dag=dag 
    )

    trino_minio_table = TrinoOperator(
        task_id="trino_create_table_minio",
        trino_conn_id='trino_conn',
        sql=f"""create table if not exists minio.trino.customers (
            id INT, 
            name VARCHAR,
            country VARCHAR,
            modify_date timestamp) 
            with (external_location = 's3a://trino/customers')""",
        dag=dag 
    )

    trino_insert = TrinoOperator(
        task_id="trino_insert",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO minio.trino.customers(id, name, country, modify_date) 
            SELECT id, name, country, modify_date from postgresql_src.public.customers""",
        dag=dag
    )

trino_minio_schema >> trino_minio_table >> trino_insert