'''Данный даг можно заменить скриптом, создающим таблицы в базах данных при 
создании соответсвующих контейнеров'''
from airflow import DAG
from datetime import datetime, timedelta
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.hooks.postgres_hook import PostgresHook


def success_callback(context):
    dag_run = context.get("dag_run")
    task_instances = dag_run.get_task_instances()
    print("These task instances succeeded:", task_instances)


def failure_callback(context):
    task_instance = context['task_instance']
    error_message = str(context["exception"])
    task_id = task_instance.task_id
    dag_id = task_instance.dag_id
    end_date = task_instance.end_date
    print(f'Task {task_id} of DAG {dag_id} failed with message: {error_message} at {end_date}')
    # return task_id, dag_id, end_date, error_message
    dest = PostgresHook(postgres_conn_id='postgres_dwh')
    table = 'dag_logs'
    rows = [(dag_id, task_id, end_date, error_message)]
    cols = ['dag_id', 'task_id', 'run_time', 'error_message']
    dest.insert_rows(table, rows = rows, target_fields = cols, commit_every = 0)


# Define default_args dict to pass to the DAG's constructor
default_args = {
    'owner': 'plsv',
    'start_date': datetime(2023, 1, 1),
    'depends_on_past': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=1),
    'on_success_callback': success_callback,
    'on_failure_callback': failure_callback
}

# Create a DAG instance
with DAG (dag_id='create_tables_context',
        default_args=default_args,          
        schedule_interval=None,
        catchup=False,
        tags=['create tables context test'],
) as dag:
    
    #tasks to create tables in source database
    create_customer_tbl_in_src = PostgresOperator(
        task_id = 'create_customer_tbl_in_src',
        postgres_conn_id = 'postgres_src',
        sql = "sql/src_customers_schema.sql",
        dag=dag
    )
    
    create_sales_tbl_in_src = PostgresOperator(
        task_id = 'create_sales_tbl_in_src',
        postgres_conn_id = 'postgres_srcm',
        sql = "sql/src_sales_schema.sql",
        dag=dag
    )


create_customer_tbl_in_src
create_sales_tbl_in_src