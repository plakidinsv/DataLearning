from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator


default_args = {
    'owner': 'plsv',
    'retries': 5,
    'retry_delay': timedelta(minutes=5)
}


with DAG(
    dag_id='dag_with_postgres_operator',
    default_args=default_args,
    start_date=datetime(2022, 8, 15),
    schedule_interval=None
) as dag:
    task1 = PostgresOperator(
        task_id='create_postgres_table',
        postgres_conn_id='postgres',
        sql="""
            create table if not exists dag_runs (
                dt date,
                dag_id varchar,
                primary key (dt, dag_id)
            )
        """
    )

 
    task1