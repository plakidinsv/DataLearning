## Criminal Spreading Project

## Description

Goal of CSProject are:
 - representing the current criminal situation by state and the largest cities in the states, ordered by crime category for purposes finding the most safity location to live
 - criminal dynamic at each location by year

###### Steps for CSProject:

- [x] 1. Finding relevant data from different sources whatever type of dataset and storaging to the project 'data source'  (original data source https://ucr.fbi.gov/crime-in-the-u.s/)
- [x] 2. Extracting data to the object storage 
- [x] 3. Cleaning and conforming data (errors, deduplication, etc.) 
- [x] 4. Definding data model
- [ ] 5. Transform data
- [x] 6. Load data to DWH
- [ ] 7. Making a data visualization

###### Tools:

ETL: dbt as Transformation tool, Apache Airflow - orchestrator  
DWH DB: PostgreSQL   
PL: SQL, Python (pandas library)   
Visualization: Apache Superset/Tableau  
S3 object storaje: minIO   

## Creating 'Micro-Data-Lake' infrastructure for project

2. Building images

```shell
docker compose build
```

2. Initialize the metadata db

```shell
docker compose run --rm airflow-cli db init
```

3. Create an admin user

```shell
docker compose run --rm airflow-cli users create --email airflow@example.com --firstname airflow --lastname airflow --password airflow --username airflow --role Admin
```

4. Start all services

```shell
docker compose up -d
```
