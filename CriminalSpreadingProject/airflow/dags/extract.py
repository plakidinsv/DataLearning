from os import requests
from airflow import DAG
from datetime import datetime, timedelta
from airflow.operators.python import PythonOperator

FILENAME = os.path.dirname('C:\Users\plaki\Documents\DataLearning\CriminalSpreadingProject\Source')
print(FILENAME)

def download_data():
    pass


with DAG(
    'CSProject',
    schedule_interval=timedelta(days=1),
    start_date=datetime(2021, 1, 1),
    catchup=False,
    tags=['extract_raw_data'],
) as dag:
    
    operator_1 = PythonOperator(
        task_id='download_data',
        python_callable=download_data,
        dag=dag
    )
