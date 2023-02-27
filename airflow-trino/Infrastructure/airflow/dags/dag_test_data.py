from airflow import DAG
from datetime import datetime, timedelta
from airflow.providers.trino.operators.trino import TrinoOperator
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
with DAG (dag_id='test_data',
        default_args=default_args,          
        schedule_interval=None,
        catchup=False,
        tags=['test'],
) as dag:
    
    products_insert = TrinoOperator(
        task_id="products_insert",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_src.public.products(name, groupname, modify_date)
                VALUES ('OLVARIT APPLE WITH BISCUIT 200G', 'FOOD FRUIT JARS', cast('2022-05-13' as date)),
                ('OLVARIT BANANA APPLE COOKIE CRUMBLE 200G', 'FOOD FRUIT JARS', cast('2022-05-13' as date)),
                ('OLVARIT APPLE BANANA ORANGE BISCUIT 200G', 'FOOD FRUIT JARS', cast('2022-06-13' as date)),
                ('OLVARIT APPLE PEACH APRICOT BISCUIT 200G', 'FOOD FRUIT JARS', cast('2022-06-15' as date)),
                ('OLVARIT APRICOT APPLE BANANA 2X200G', 'FOOD FRUIT JARS', cast('2022-07-10' as date)),
                ('BISCUITS CEREALS', 'FOOD PLAIN CEREALS', cast('2022-07-12' as date)),
                ('NUTRILON A.R. 1 4X(5X22G)', 'MILK IFFO SPECIALS', cast('2022-07-13' as date)),
                ('NUTRILON PEPTI 1 4X(5X22,7G)', 'MILK IFFO SPECIALS', cast('2022-08-13' as date)),
                ('NUTRILON B.M.F 4X50X2.2G', 'MILK IFFO SPECIALS', cast('2022-08-13' as date)),
                ('OLV 8M858 BANANA STRAW 90G', 'FOOD FRUIT POUCHES', cast('2022-08-13' as date)),
                ('OLV 8M862 APRICOT PEAR BANANA 90G', 'FOOD FRUIT POUCHES', cast('2022-09-05' as date)),
                ('OLV 12M863 STRAWBERRY BANANA KIWI 90G', 'FOOD FRUIT POUCHES', cast('2022-09-06' as date)),
                ('OLV 6M860 APPLE BANANA 90G', 'FOOD FRUIT POUCHES', cast('2022-09-06' as date)),
                ('OLV 12M864 BLUEBERRY BLACKCURRANT 90G', 'FOOD FRUIT POUCHES', cast('2022-09-06' as date)),
                ('OLV 6M859 PEAR APPLE 90G', 'FOOD FRUIT POUCHES', cast('2022-09-06' as date)),
                ('OLV 12M866 FOREST FRUIT YOG 90G', 'FOOD FRUIT POUCHES', cast('2022-09-06' as date)),
                ('OLV 12M865 EXOTIC MANGO 90G', 'FOOD FRUIT POUCHES', cast('2022-12-20' as date)),
                ('NTRLN EX-PREMATURE, BLG 6X800G', 'MILK IFFO SPECIALS', cast('2022-12-20' as date)),
                ('OLVARIT 7 CEREALS 6X200G', 'FOOD PLAIN CEREALS', cast('2022-12-20' as date)),
                ('OLVARIT APPLE MANGO BANANA', 'FOOD FRUIT JARS', cast('2022-12-29' as date))"""
    )

    customers_insert = TrinoOperator(
        task_id="customers_insert",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_src.public.customers(name, country, modify_date) 
                VALUES ('Ivanova Maria', 'Ukraine', cast('2022-01-13' as date)),
                ('Ivanov Ivan', 'Russia', cast('2022-01-20' as date)),
                ('Montgomery Berns', 'USA', cast('2022-01-23' as date)),
                ('Eugenii Marchenko', 'Ukraine', cast('2022-02-02' as date)),
                ('Carmen Electra', 'USA', cast('2022-02-03' as date)),
                ('Richard Mayer', 'Germany', cast('2022-03-13' as date)),
                ('Alex McLane', 'Canada', cast('2022-03-13' as date)),
                ('Johnny Depp', 'USA', cast('2022-10-13' as date)),
                ('John Simpson', 'USA', cast('2022-12-20' as date))"""
    )

    sales_insert = TrinoOperator(
        task_id="sales_insert",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_src.public.sales(customer_id, product_id, qty, modify_date) 
                VALUES (1, 6, 6, cast('2022-08-14' as date)),
                (4, 3, 2, cast('2022-08-14' as date)),
                (5, 1, 10, cast('2022-08-14' as date)),
                (2, 20, 6, cast('2022-02-13' as date)),
                (6, 18, 15, cast('2022-03-23' as date)),
                (7, 17, 10, cast('2022-06-13' as date)),
                (6, 10, 27, cast('2022-05-13' as date)),
                (8, 18, 24, cast('2022-10-14' as date)),
                (9, 17, 10, cast('2022-12-21' as date))"""
    )

    high_watermark_insert = TrinoOperator(
        task_id="high_watermark_insert",
        trino_conn_id='trino_conn',
        sql=f"""INSERT INTO postgresql_dwh.public.high_watermark(name_table, watermark_value) 
                VALUES ('customers', cast('2022-01-14' as date)),
                ('sales', cast('2022-01-14' as date)),
                ('products', cast('2022-01-14' as date))"""
    )    

products_insert
customers_insert
sales_insert
high_watermark_insert
