from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator


default_args = {
    'owner': 'plsv',
    'retries': 5,
    'retry_delay': timedelta(minutes=5)
}


with DAG(
    dag_id='drop_create_tbl_in_pg_db',
    default_args=default_args,
    start_date=datetime(2022, 8, 27),
    schedule_interval=None
) as dag:
    drop_tbl_if_exists = PostgresOperator(
        task_id='drop_tbl_if_exists',
        postgres_conn_id='postgres',
        sql="""
            DROP TABLE IF EXISTS test_connection;
            """
    )
    create_tbl=PostgresOperator(
        task_id='create_tbl',
        postgres_conn_id='postgres',
        sql="""
            CREATE TABLE test_connection (
                dt date,
                dag_id varchar,
                primary key (dt, dag_id)
            );
        """
    )

    drop_tbl_if_exists >> create_tbl