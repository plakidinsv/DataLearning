import os
from datetime import datetime
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook


def upload_file(ds, **kwargs):
    # Upload files from local to Minio
    path = os.listdir('C:/Users/plaki/Documents/GitHub/DataLearning/prjct/Source') # вынести в переменную
    for file in path:
        s3 = S3Hook('minio_conn')
        s3.load_file(file,
                     key=file,
                     bucket_name="prjct.raw.data")

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

