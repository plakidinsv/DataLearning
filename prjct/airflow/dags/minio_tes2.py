from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor 


default_args = {
    'owner': 'coder2j',
    'retries': 5,
    'retry_delay': timedelta(minutes=10)
}


with DAG(
    dag_id='dag__minio_s3_sensor',
    start_date=datetime(2022, 8, 11),
    schedule_interval=None,
    default_args=default_args
) as dag:
    task1 = S3KeySensor(
        task_id='sensor_minio_s3',
        bucket_name='miniobucket',
        bucket_key="test/my-test-upload-file.txt",
        aws_conn_id='minio_conn',
        mode='poke',
        poke_interval=5,
        timeout=30
    )

task1