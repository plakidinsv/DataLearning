import os
from sqlalchemy import create_engine
import geopandas as gpd
import psycopg2 as pg
from datetime import datetime
from airflow import DAG
from airflow.operators.python_operator import PythonOperator



default_args = {
    'owner': 'plsv'
}

def create_geo_subdiv_dump_for_pg(ds, **kwargs):
    source = os.listdir('./Source/geo/us_cousib_2019')
    file = 'cb_2019_us_cousub_500k.shp'
    db_connection_url = "postgresql+psycopg2://postgres:postgres@host.docker.internal:5431/postgres"
    con = create_engine(db_connection_url)

    # read in the data
    gdf = gpd.read_file(f'./Source/geo/us_cousib_2019/{file}')

    # Drop nulls in the geometry column
    print('Dropping ' + str(gdf.geometry.isna().sum()) + ' nulls.')
    gdf = gdf.dropna(subset=['geometry'])

    # Push the geodataframe to postgresql
    gdf.to_postgis("us_cousub_2019", con, index=False, if_exists='replace')


def create_gis_dump_for_pg(ds, **kwargs):
    source = os.listdir('./Source/geo/us_county_2019')
    file = 'cb_2019_us_county_20m.shp'
    db_connection_url = "postgresql+psycopg2://postgres:postgres@host.docker.internal:5431/postgres"
    con = create_engine(db_connection_url)

    # read in the data
    gdf = gpd.read_file(f'./Source/geo/us_county_2019/{file}')

    # Drop nulls in the geometry column
    print('Dropping ' + str(gdf.geometry.isna().sum()) + ' nulls.')
    gdf = gdf.dropna(subset=['geometry'])

    # Push the geodataframe to postgresql
    gdf.to_postgis("us_county_2019", con, index=False, if_exists='replace')


def create_geo_state_for_pg(ds, **kwargs):
    source = os.listdir('./Source/geo/us_state_2019')
    file = 'cb_2019_us_state_20m.shp'
    db_connection_url = "postgresql+psycopg2://postgres:postgres@host.docker.internal:5431/postgres"
    con = create_engine(db_connection_url)

    # read in the data
    gdf = gpd.read_file(f'./Source/geo/us_state_2019/{file}')

    # Drop nulls in the geometry column
    print('Dropping ' + str(gdf.geometry.isna().sum()) + ' nulls.')
    gdf = gdf.dropna(subset=['geometry'])

    # Push the geodataframe to postgresql
    gdf.to_postgis("us_state_2019", con, index=False, if_exists='replace') 



with DAG (dag_id='load_geo_county_divisions_to_postgres',
        default_args=default_args,
        start_date=datetime(2022, 8, 25),  
        schedule_interval=None,
        catchup=False,
        tags=['minio'],
) as dag:
    
    t1 = PythonOperator(
        task_id = 'create_geo_county_subdivisions_for_pg',
        provide_context = True,
        python_callable = create_geo_subdiv_dump_for_pg
    )

    t2 = PythonOperator(
        task_id = 'create_gis_dump_for_pg',
        provide_context = True,
        python_callable = create_gis_dump_for_pg
    )

    t3 = PythonOperator(
        task_id = 'create_geo_state_for_pg',
        provide_context = True,
        python_callable = create_geo_state_for_pg
    )

t1, t2, t3