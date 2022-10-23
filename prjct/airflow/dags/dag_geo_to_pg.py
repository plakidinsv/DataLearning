import os
import pandas as pd
from sqlalchemy import create_engine
import geopandas as gpd
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

def upload_file(ds, **kwargs):
    # Upload files from local to MinIO
    source = os.listdir('./Source/geo')
    file = 'uszips.csv'
    s3 = S3Hook('minio_conn')
    s3.load_file(f'./Source/geo/{file}',
                key=file,
                bucket_name='prjct.transfom.bucket')
        

def copy_raw_data_to_db(ds, **kwargs):
    engine = create_engine("postgresql+psycopg2://postgres:postgres@host.docker.internal:5431/postgres")
    source_bucket_name = 'prjct.transfom.bucket'
    file = 'uszips.csv'
    s3 = S3Hook('minio_conn')
 
    print(f'I have found {file} in {source_bucket_name}')
    response = s3.read_key(key=file, bucket_name=source_bucket_name)
    for df in pd.read_csv(StringIO(response), chunksize=1000):
        df.to_sql(
          name = 'us_zip', 
          schema = 'public',
          con = engine,
          index=False,
          if_exists='append')


def create_gis_dump_for_pg(ds, **kwargs):
    source = os.listdir('./Source/geo')
    file = 'cb_2019_us_county_20m.shp'
    db_connection_url = "postgresql+psycopg2://postgres:postgres@host.docker.internal:5431/postgres"
    con = create_engine(db_connection_url)

    # read in the data
    gdf = gpd.read_file(f'./Source/geo/{file}')

    # Drop nulls in the geometry column
    print('Dropping ' + str(gdf.geometry.isna().sum()) + ' nulls.')
    gdf = gdf.dropna(subset=['geometry'])

    # Push the geodataframe to postgresql
    gdf.to_postgis("us_county_2019", con, index=False, if_exists='replace') 



with DAG (dag_id='load_zips_to_s3_to_postgres',
        default_args=default_args,
        start_date=datetime(2022, 8, 25),  
        schedule_interval=None,
        catchup=False,
        tags=['minio'],
) as dag:
    
    t1 = PythonOperator(
        task_id='upload_file',
        provide_context=True,
        python_callable=upload_file
    )

    t2 = PostgresOperator(
        task_id = 'create_postgres_zip_table',
        postgres_conn_id = 'postgres_default',
        sql = "sql/zip_schema.sql"
    )

    t3 = PythonOperator(
        task_id = 'copy_zip_data_to_db',
        provide_context = True,
        python_callable = copy_raw_data_to_db
    )

    t4 = PythonOperator(
        task_id = 'create_gis_dump_for_pg',
        provide_context = True,
        python_callable = create_gis_dump_for_pg
    )

t1 >> t2 >> t3 >> t4