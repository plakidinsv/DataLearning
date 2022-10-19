import os
import pandas as pd
from sqlalchemy import create_engine
import psycopg2 as pg
from io import StringIO
from datetime import datetime
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.providers.postgres.operators.postgres import PostgresOperator


default_args = {
    'owner': 'plsv'
}


def convert_file(ds, **kwargs):
    # Upload files from local to MinIO
    # adds year column and some cleaning on fly
    source = os.listdir('./Source')
    for file in source:
        if file.endswith('.xls'):            
            df = pd.read_excel(f'./Source/{file}')
            df.columns = df.columns.str.lower().str.replace("\n", " ").str.replace(" ", "_").str.replace("\d", "")
            df = df.assign(year=file[-8:-4]+'-12'+'-31')
            df['year'] = pd.to_datetime(df['year'])
            df['state'] = df['state'].str.replace("\d", "")
            df['city'] = df['city'].str.replace("\d", "")
            cleanfilename=file.replace('.xls', '')
            csvname = cleanfilename + '.csv'
            df.to_csv(f'./Source/{csvname}', index = False) 


def upload_file(ds, **kwargs):
    # Upload files from local to MinIO
    source = os.listdir('./Source') # вынести в переменную  
    for file in source:
        if file.endswith('.csv'):
            s3 = S3Hook('minio_conn')
            s3.load_file(f'./Source/{file}',
                       key=file,
                       bucket_name='prjct.raw.data')
        

def copy_file(ds, **kwargs):
    # Copy files from raw bucket MinIO to transformation bucket MinIO
    s3 = S3Hook('minio_conn')
    source_keys=s3.list_keys(bucket_name='prjct.raw.data')
    
    for file in source_keys:
        s3.copy_object(source_bucket_key=file,
                dest_bucket_key=file[-8:],
                source_bucket_name='prjct.raw.data',
                dest_bucket_name='prjct.transfom.bucket')


def copy_raw_data_to_db(ds, **kwargs):
    engine = create_engine("postgresql+psycopg2://postgres:postgres@host.docker.internal:5431/postgres")
    source_bucket_name = 'prjct.transfom.bucket'
    s3 = S3Hook('minio_conn')
    source_keys=s3.list_keys(bucket_name=source_bucket_name)
 
    for file in source_keys:
        print(f'I have found {file} in {source_bucket_name}')
        response = s3.read_key(key=file, bucket_name=source_bucket_name)
        for df in pd.read_csv(StringIO(response), chunksize=1000):
            df.to_sql(
              name = 'crime', 
              schema = 'public',
              con = engine,
              index=False,
              if_exists='append')


with DAG (dag_id='load_local_to_minio',
        start_date=datetime(2022, 8, 25),  
        schedule_interval=None,
        catchup=False,
        tags=['minio'],
) as dag:
    
    # Create a task to call your processing function
    t1 = PythonOperator(
        task_id='convert_file_task',
        provide_context=True,
        python_callable=convert_file
    )

    t2 = PythonOperator(
        task_id='upload_file_task',
        provide_context=True,
        python_callable=upload_file
    )

    t3 = PythonOperator(
        task_id='copy_file_to_transformation_bucket',
        provide_context=True,
        python_callable=copy_file
    )

    t4 = PostgresOperator(
        task_id = 'create_postgres_fact_table',
        postgres_conn_id = 'postgres_default',
        sql = "sql/crime_schema.sql"
    )

    t5 = PythonOperator(
        task_id = 'copy_raw_data_to_db',
        provide_context = True,
        python_callable = copy_raw_data_to_db
    )

t1 >> t2 >> t3 >> t4 >> t5


''' 
*** NEXT STEPS*** 

load data from s3 to db
dbt task
'''