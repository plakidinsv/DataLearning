import os
import pandas as pd
from pathlib import Path
import geopandas as gpd
from sqlalchemy import create_engine

source = os.listdir('./test')
file = 'cb_2019_us_county_20m.shp'
db_connection_url = "postgresql://postgres:1@localhost:5432/geo"
con = create_engine(db_connection_url)

# read in the data
gdf = gpd.read_file('test/cb_2019_us_county_20m.shp')

# Drop nulls in the geometry column
print('Dropping ' + str(gdf.geometry.isna().sum()) + ' nulls.')
gdf = gdf.dropna(subset=['geometry'])

# Push the geodataframe to postgresql
gdf.to_postgis("redlining", con, index=False, if_exists='replace') 



for file in source:
    cleanfilename=file.replace('.xls', '')
    df = pd.read_excel(f'./test/{file}')
    df.columns = df.columns.str.lower().str.replace("\n", " ").str.replace(" ", "_").str.replace("\d", "")
    df = df.assign(year=file[-8:-4]+'-12'+'-31')
    df['year'] = pd.to_datetime(df['year'])
    df['state'] = df['state'].str.replace("\d", "")
    print(df.dtypes)
    csvname = cleanfilename + '.csv'
    df.to_csv(f'./test/{csvname}', index = False) 


def convert_file(ds, **kwargs):
    source = os.listdir('./Source')
    for file in source:
        if file.endswith('.xls'):            
            df = pd.read_excel(f'./Source/{file}')
            df.columns = df.columns.str.lower().str.replace("-", "").str.replace("\n", " ").str.replace(" ", "_").str.replace("\d", "")
            df = df.assign(year=file[-8:-4]+'-12'+'-31')
            df['year'] = pd.to_datetime(df['year'])
            df['state'] = df['state'].str.replace("\d", "")
            cleanfilename=file.replace('.xls', '')
            csvname = cleanfilename + '.csv'
            df.to_csv(f'./Source/{csvname}', index = False) 

# with os.scandir('./Source') as source:
#     for file in source:
#         print(file)
'''
source = './Source'


for file in os.listdir(source):
    print((f'./Source{file}'))
    # print(file)


source = './Source'
s = os.listdir(source)
print(s)

l = pathlib.Path('./Source')
k = source.iterdir()
print(k)

df = pd.read_excel('./Source/05tbl08_2005.xls')
df.to_csv('./Source/05tbl08_2005.csv', index=False)

for file in os.listdir(source):
    df = pd.read_excel(f'./Source/{file}')
    tr = df.to_csv(f'./Source/{file}', index=False)
'''

source = os.listdir('./Source') # вынести в переменную
for file in source:
    if file.endswith('.xls'):
        cleanfilename=file.replace('.xls', '')
        df = pd.read_excel(f'./Source/{file}')
        csvname = cleanfilename + '.csv'
        df.to_csv(f'./Source/{csvname}', index = False)


source = os.listdir('./test')

for file in source:
    cleanfilename=file.replace('.xls', '')
    df = pd.read_excel(f'./test/{file}')
    df.assign(year=file[-8:-4])
    csvname = cleanfilename + '.csv'
    df.to_csv(f'./test/{csvname}', index = False) 

l = 'arson1'
l = l.replace('1', '')
print(l.isalpha(), l)



