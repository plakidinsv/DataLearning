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


def create_gis_dump_for_pg(ds, **kwargs):
    source = os.listdir('./Source/geo')
    file = 'cb_2019_us_county_20m.shp'
    db_connection_url = "postgresql+psycopg2://postgres:postgres@host.docker.internal:5431/geodata"
    con = create_engine(db_connection_url)

    # read in the data
    gdf = gpd.read_file(f'./Source/geo/{file}')

    # Drop nulls in the geometry column
    print('Dropping ' + str(gdf.geometry.isna().sum()) + ' nulls.')
    gdf = gdf.dropna(subset=['geometry'])

    # Push the geodataframe to postgresql
    gdf.to_postgis("us_county_2019", con, index=False, if_exists='replace') 



with DAG (dag_id='geo-db_postgres_test',
        default_args=default_args,
        start_date=datetime(2022, 8, 25),  
        schedule_interval=None,
        catchup=False,
        tags=['minio'],
) as dag:

    t1 = PostgresOperator(
        task_id = 'create_gis_extension',
        postgres_conn_id = 'postgres_default',
        sql = "sql/create_gis_extension.sql",
        autocommit = True
    )


t1 