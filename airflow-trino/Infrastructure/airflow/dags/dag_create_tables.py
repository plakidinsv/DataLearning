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
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    'on_success_callback': success_callback,
    'on_failure_callback': failure_callback
}

# Create a DAG instance
with DAG (dag_id='create_tables_in_databases',
        default_args=default_args,          
        schedule_interval=None,
        catchup=False,
        tags=['create tables in bases'],
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
        postgres_conn_id = 'postgres_src',
        sql = "sql/src_sales_schema.sql",
        dag=dag
    )

    create_products_tbl_in_src = PostgresOperator(
        task_id = 'create_products_tbl_in_src',
        postgres_conn_id = 'postgres_src',
        sql = "sql/src_products_schema.sql",
        dag=dag
    )

    #tasks to create tables in mrr database
    create_customer_tbl_in_mrr = PostgresOperator(
        task_id = 'create_customer_tbl_in_mrr',
        postgres_conn_id = 'postgres_dwh',
        database = 'mrr',
        sql = "sql/mrr_customers_schema.sql",
        dag=dag
    )

    create_sales_tbl_in_mrr = PostgresOperator(
        task_id = 'create_sales_tbl_in_mrr',
        postgres_conn_id = 'postgres_dwh',
        database = 'mrr',
        sql = "sql/mrr_sales_schema.sql",
        dag=dag
    )

    create_products_tbl_in_mrr = PostgresOperator(
        task_id = 'create_products_tbl_in_mrr',
        postgres_conn_id = 'postgres_dwh',
        database = 'mrr',
        sql = "sql/mrr_products_schema.sql",
        dag=dag
    )

    #tasks to create tables in stg database
    create_src_customer_tbl_in_stg = PostgresOperator(
        task_id = 'create_customer_tbl_in_stg',
        postgres_conn_id = 'postgres_dwh',
        database = 'stg',
        sql = "sql/stg_src_customers_schema.sql",
        dag=dag
    )

    create_src_sales_tbl_in_stg = PostgresOperator(
        task_id = 'create_sales_tbl_in_stg',
        postgres_conn_id = 'postgres_dwh',
        database = 'stg',
        sql = "sql/stg_src_sales_schema.sql",
        dag=dag
    )

    create_src_products_tbl_in_stg = PostgresOperator(
        task_id = 'create_products_tbl_in_stg',
        postgres_conn_id = 'postgres_dwh',
        database = 'stg',
        sql = "sql/stg_src_products_schema.sql",
        dag=dag
    )
    create_stg_customer_tbl_in_stg = PostgresOperator(
        task_id = 'create_stg_customer_tbl_in_stg',
        postgres_conn_id = 'postgres_dwh',
        database = 'stg',
        sql = "sql/stg_stg_customers_schema.sql",
        dag=dag
    )

    create_stg_sales_tbl_in_stg = PostgresOperator(
        task_id = 'create_stg_sales_tbl_in_stg',
        postgres_conn_id = 'postgres_dwh',
        database = 'stg',
        sql = "sql/stg_stg_sales_schema.sql",
        dag=dag
    )

    create_stg_products_tbl_in_stg = PostgresOperator(
        task_id = 'create_stg_products_tbl_in_stg',
        postgres_conn_id = 'postgres_dwh',
        database = 'stg',
        sql = "sql/stg_stg_products_schema.sql",
        dag=dag
    )

    create_high_watermark_tbl_in_stg = PostgresOperator(
        task_id = 'create_high_watermark_tbl_in_stg',
        postgres_conn_id = 'postgres_dwh',
        database = 'stg',
        sql = "sql/stg_high_watermark_schema.sql",
        dag=dag
    )

    #tasks to create tables in dwh tabase
    create_customer_tbl_in_dwh = PostgresOperator(
        task_id = 'create_customer_tbl_in_dwh',
        postgres_conn_id = 'postgres_dwh',
        database = 'dwh',
        sql = "sql/dwh_customers_schema.sql",
        dag=dag
    )

    create_sales_tbl_in_dwh = PostgresOperator(
        task_id = 'create_sales_tbl_in_dwh',
        postgres_conn_id = 'postgres_dwh',
        database = 'dwh',
        sql = "sql/dwh_sales_schema.sql",
        dag=dag
    )

    create_products_tbl_in_dwh = PostgresOperator(
        task_id = 'create_products_tbl_in_dwh',
        postgres_conn_id = 'postgres_dwh',
        database = 'dwh',
        sql = "sql/dwh_products_schema.sql",
        dag=dag
    )

    create_high_watermark_tbl_in_dwh = PostgresOperator(
        task_id = 'create_high_watermark_tbl_in_dwh',
        postgres_conn_id = 'postgres_dwh',
        database = 'dwh',
        sql = "sql/dwh_high_watermark_schema.sql",
        dag=dag
    )

    create_stored_routines_tbl_in_dwh = PostgresOperator(
        task_id = 'create_stored_routines_tbl_in_dwh',
        postgres_conn_id = 'postgres_dwh',
        database = 'dwh',
        sql = "sql/dwh_stored_routines_schema.sql",
        dag=dag
    )

    create_dag_logs_tbl_in_dwh = PostgresOperator(
        task_id = 'create_dag_logs_tbl_in_dwh',
        postgres_conn_id = 'postgres_dwh',
        database = 'dwh',
        sql = "sql/dwh_dag_logs_schema.sql",
        dag=dag
    )

    create_procedure_errors_tbl_in_dwh = PostgresOperator(
        task_id = 'create_procedure_errors_tbl_in_dwh',
        postgres_conn_id = 'postgres_dwh',
        database = 'dwh',
        sql = "sql/dwh_procedure_errors_schema.sql",
        dag=dag
    )

create_customer_tbl_in_src
create_sales_tbl_in_src
create_products_tbl_in_src
create_customer_tbl_in_mrr
create_sales_tbl_in_mrr
create_products_tbl_in_mrr
create_src_customer_tbl_in_stg
create_src_sales_tbl_in_stg
create_src_products_tbl_in_stg
create_stg_customer_tbl_in_stg
create_stg_sales_tbl_in_stg
create_stg_products_tbl_in_stg
create_high_watermark_tbl_in_stg
create_customer_tbl_in_dwh
create_sales_tbl_in_dwh
create_products_tbl_in_dwh
create_high_watermark_tbl_in_dwh
create_stored_routines_tbl_in_dwh
create_dag_logs_tbl_in_dwh
create_procedure_errors_tbl_in_dwh