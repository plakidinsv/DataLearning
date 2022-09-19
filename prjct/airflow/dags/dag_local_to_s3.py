import os
from datetime import datetime
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook

'''
add tasks:
- check connection to s3
    if ok
    - upload files
    else
    - send email
- rename files in s3 storage
- dbt-dag 
    - rename file
    - verify data in files
- create tables in RDBMS
- add data to RDBMS
'''

def upload_file(ds, **kwargs):
    # Upload files from local to MinIO
    source = os.listdir('./Source') # вынести в переменную
    
    for file in source:
        s3 = S3Hook('minio_conn')
        s3.load_file(f'./Source/{file}',
                     key=file,
                     bucket_name='prjct.raw.data')


def copy_file(ds, **kwarfs):
    # Copy files from raw bucket MinIO to transformation bucket MinIO
    s3 = S3Hook('minio_conn')
    source_keys=s3.list_keys(bucket_name='prjct.raw.data')
    
    for file in source_keys:
        s3 = S3Hook('minio_conn')
        s3.copy_object(source_bucket_key=file,
                        dest_bucket_key=file,
                        source_bucket_name='prjct.raw.data',
                        dest_bucket_name='prjct.transfom.bucket')


with DAG (dag_id='load_local_to_minio',
        start_date=datetime(2022, 8, 25),  
        schedule_interval=None,
        catchup=False,
        tags=['minio'],
) as dag:
    
    # Create a task to call your processing function
    t1 = PythonOperator(
        task_id='upload_file_task',
        provide_context=True,
        python_callable=upload_file
    )

    t2 =PythonOperator(
        task_id='copy_file_to_transformation_bucket',
        provide_context=True,
        python_callable=copy_file
    )

t1 >> t2
