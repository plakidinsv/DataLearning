import os
from sqlalchemy import create_engine
import geopandas as gpd
import psycopg2 as pg


def create_geo_state_for_pg(**kwargs):
    source = os.listdir('C:/Users/plaki/Documents/GitHub/DataLearning/prjct/airflow/Source/geo/us_state_2019')
    file = 'cb_2019_us_state_20m.shp'
    db_connection_url = "postgresql+psycopg2://postgres:1@localhost:5432/geo"
    con = create_engine(db_connection_url)

    # read in the data
    gdf = gpd.read_file(f'C:/Users/plaki/Documents/GitHub/DataLearning/prjct/airflow/Source/geo/us_state_2019/{file}')

    # Drop nulls in the geometry column
    print('Dropping ' + str(gdf.geometry.isna().sum()) + ' nulls.')
    gdf = gdf.dropna(subset=['geometry'])

    # Push the geodataframe to postgresql
    gdf.to_postgis("us_state_2019", con, index=False, if_exists='replace') 

create_geo_state_for_pg()