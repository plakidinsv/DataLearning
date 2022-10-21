import pandas as pd
from sqlalchemy import create_engine
import psycopg2 as pg
from io import StringIO
from datetime import datetime
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook

default_args = {
    'owner': 'plsv'
}

def copy_raw_data_to_db(ds, **kwargs):
    engine = create_engine("postgresql+psycopg2://postgres:postgres@host.docker.internal:5431/postgres")
    source_bucket_name = 'prjct.transfom.bucket'
    s3 = S3Hook('minio_conn')
    source_keys=s3.list_keys(bucket_name=source_bucket_name)
 
    for file in source_keys:
        if file == '2005.csv':
            print(f'I have found {file} in {source_bucket_name}')
            response = s3.read_key(key=file, bucket_name=source_bucket_name)
            for df in pd.read_csv(StringIO(response), chunksize=1000):
                df.to_sql(
                  name = 'crime', 
                  schema = 'public',
                  con = engine,
                  index=False,
                  if_exists='append')



with DAG (dag_id='minio_to_postgres',
        default_args=default_args,
        start_date=datetime(2022, 8, 25),  
        schedule_interval=None,
        catchup=False,
        tags=['minio'],
) as dag:
    
    t1 = PythonOperator(
        task_id = 'copy_raw_data_to_db',
        provide_context = True,
        python_callable = copy_raw_data_to_db
    )

t1 
