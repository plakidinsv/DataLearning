from airflow import DAG
from datetime import datetime, timedelta
import pendulum
from airflow.providers.trino.operators.trino import TrinoOperator
from airflow.operators.empty import EmptyOperator
from airflow.operators.python_operator import PythonOperator
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


def load_dwh_watermark():
    src = PostgresHook(postgres_conn_id='postgres_stg')
    dest = PostgresHook(postgres_conn_id='postgres_dwh')
    src_conn = src.get_conn()
    cursor = src_conn.cursor()
    dest_conn = dest.get_conn()
    dest_cursor = dest_conn.cursor()

    cursor.execute("SELECT name_table, watermark_value FROM stg_high_watermark")
    src_data = cursor.fetchall()
    for row in src_data:
        dest.run(f"UPDATE high_watermark SET watermark_value = cast('{row[1]}' as date) WHERE name_table = '{row[0]}'")
    cursor.close()


def truncate_tables():
    pg_hook = PostgresHook(postgres_conn_id='postgres_stg')
    conn = pg_hook.get_conn()
    cursor = conn.cursor()
    tables = ['public.src_dim_customers',
            'public.stg_dim_customers',
            'public.src_dim_products',
            'public.stg_dim_products',
            'public.src_fact_sales',
            'public.stg_fact_sales',
            'public.stg_high_watermark']
    for table in tables:
        cursor.execute(f'TRUNCATE TABLE {table}')
    cursor.close()
    conn.commit()

# Define default_args dict to pass to the DAG's constructor
default_args = {
    'owner': 'plsv',
    'start_date': datetime(2023, 1, 17),
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(seconds=20),
    'on_success_callback': success_callback,
    'on_failure_callback': failure_callback
}

# Create a DAG instance
with DAG (dag_id='dag_etl',
        default_args=default_args,          
        schedule_interval=None,
        catchup=True,
        tags=['test']
) as dag:
    
    copy_src_customers_to_mrr = TrinoOperator(
        task_id="copy_customers_to_mrr",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_mrr.public.dim_customers(id, name, country, modify_date) 
            SELECT id, name, country, modify_date FROM postgresql_src.public.customers AS src
            WHERE src.modify_date > (SELECT watermark_value FROM postgresql_dwh.public.high_watermark
                                    WHERE name_table='customers')""",
        dag=dag
    )
    
    copy_src_products_to_mrr = TrinoOperator( 
        task_id="copy_products_to_mrr",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_mrr.public.dim_products(id, name, groupname, modify_date) 
            SELECT id, name, groupname, modify_date FROM postgresql_src.public.products AS src
            WHERE src.modify_date > (SELECT watermark_value FROM postgresql_dwh.public.high_watermark
                                    WHERE name_table='products')""",
        dag=dag
    )

    copy_src_sales_to_mrr = TrinoOperator(
        task_id="copy_sales_to_mrr",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_mrr.public.fact_sales(customer_id, product_id, qty, modify_date) 
            SELECT customer_id, product_id, qty, modify_date FROM postgresql_src.public.sales AS src
            WHERE src.modify_date > (SELECT watermark_value FROM postgresql_dwh.public.high_watermark
                                    WHERE name_table='sales')""",
        dag=dag
    )

    waitress = EmptyOperator(
        task_id="waitress_1",
        trigger_rule='all_success',
        dag=dag
    )

###########    
    copy_mrr_customers_to_stg = TrinoOperator(
        task_id="copy_mrr_customers_to_stg",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_stg.public.src_dim_customers(id, name, country, modify_date) 
            SELECT id, name, country, modify_date FROM postgresql_mrr.public.dim_customers""",
        dag=dag
    )

    copy_mrr_products_to_stg = TrinoOperator(
        task_id="copy_mrr_products_to_stg",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_stg.public.src_dim_products(id, name, groupname, modify_date) 
            SELECT id, name, groupname, modify_date FROM postgresql_mrr.public.dim_products""",
        dag=dag
    )

    copy_mrr_sales_to_stg = TrinoOperator(
        task_id="copy_mrr_sales_to_stg",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_stg.public.src_fact_sales(customer_id, product_id, qty, modify_date) 
            SELECT customer_id, product_id, qty, modify_date FROM postgresql_mrr.public.fact_sales""",
        dag=dag
    )

    waitress_2 = EmptyOperator(
        task_id="waitress_2",
        trigger_rule='all_success',
        dag=dag
    )    

#############
    transform_stg_customers = TrinoOperator(
        task_id="transform_stg_customers",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_stg.public.stg_dim_customers(id, name, country)
            SELECT id, name, country FROM postgresql_stg.public.src_dim_customers AS src
            WHERE src.modify_date > (SELECT watermark_value FROM postgresql_dwh.public.high_watermark
                                    WHERE name_table='customers')""",
        dag=dag
    )

    transform_stg_products = TrinoOperator(
        task_id="transform_stg_products",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_stg.public.stg_dim_products(id, name, groupname)
            SELECT id, name, groupname FROM postgresql_stg.public.src_dim_products AS src
            WHERE src.modify_date > (SELECT watermark_value FROM postgresql_dwh.public.high_watermark
                                    WHERE name_table='products')""",
        dag=dag
    )

    transform_stg_sales = TrinoOperator(
        task_id="transform_stg_sales",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_stg.public.stg_fact_sales(customer_id, product_id, qty)
            SELECT customer_id, product_id, qty FROM postgresql_stg.public.src_fact_sales AS src
            WHERE src.modify_date > (SELECT watermark_value FROM postgresql_dwh.public.high_watermark
                                    WHERE name_table='sales')""",
        dag=dag
    )

    transform_stg_watermark = TrinoOperator(
        task_id="transform_stg_watermark",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_stg.public.stg_high_watermark(name_table, watermark_value) 
            SELECT 'customers', max(modify_date) FROM postgresql_stg.public.src_dim_customers
            UNION
            SELECT 'products', max(modify_date) FROM postgresql_stg.public.src_dim_products
            UNION 
            SELECT 'sales', max(modify_date) FROM postgresql_stg.public.src_fact_sales""",
        dag=dag
    )

    waitress_3 = EmptyOperator(
        task_id="waitress_3",
        trigger_rule='all_success',
        dag=dag
    )    
#################
    load_dwh_customers = TrinoOperator(
        task_id="load_dwh_customers",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_dwh.public.dim_customers(id, name, country)
            SELECT id, name, country FROM postgresql_stg.public.stg_dim_customers""",
        dag=dag
    )

    load_dwh_products = TrinoOperator(
        task_id="load_dwh_products",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_dwh.public.dim_products(id, name, groupname)
            SELECT id, name, groupname FROM postgresql_stg.public.stg_dim_products""",
        dag=dag
    )

    load_dwh_sales = TrinoOperator(
        task_id="load_dwh_sales",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_dwh.public.fact_sales(customer_id, product_id, qty)
            SELECT customer_id, product_id, qty FROM postgresql_stg.public.stg_fact_sales""",
        dag=dag
    )    

    load_dwh_watermark = PythonOperator(
        task_id='load_dwh_watermark',
        python_callable=load_dwh_watermark,
        dag=dag
    )
########
    truncate_stg_tables = PythonOperator(
        task_id='truncate_stg_tables',
        python_callable=truncate_tables,
        dag=dag
    )

[copy_src_customers_to_mrr, copy_src_products_to_mrr, copy_src_sales_to_mrr] >> waitress
waitress >> [copy_mrr_customers_to_stg, copy_mrr_products_to_stg, copy_mrr_sales_to_stg] >> waitress_2
waitress_2 >> [transform_stg_customers, transform_stg_products, transform_stg_sales, transform_stg_watermark] >> waitress_3
waitress_3 >> [load_dwh_customers, load_dwh_products, load_dwh_sales, load_dwh_watermark] >> truncate_stg_tables