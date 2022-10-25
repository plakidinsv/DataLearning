
  create view "postgres"."staging_crimespread"."view_adm_data__dbt_tmp" as (
    with crime as (
    select * from "postgres"."staging_crimespread"."stg_crime"
),
city_ext as (
    select * from "postgres"."staging_crimespread"."stg_city_state_county_ext"
),
geo_county_2019 as (
    select * from "postgres"."staging_crimespread"."stg_us_county_2019"
),
us_cities as (
    select * from "postgres"."staging_crimespread"."stg_us_cities"
),
crime_city_ext_nulls as (
    select  crime.state_name
            , city_ext.county_name
            , crime.city_name
    from crime
    left join city_ext
    on crime.state_name = city_ext.state_name 
        and 
        crime.city_name = city_ext.city_name 
    where city_ext.county_name is null
),
crime_ext_us_cities as (
    select crime_city_ext_nulls.state_name as state_name
            , us_cities.county_name as county_name
            , crime_city_ext_nulls.city_name as city_name
    from crime_city_ext_nulls
    left join us_cities
    on crime_city_ext_nulls.state_name = us_cities.state_name
        and crime_city_ext_nulls.city_name = us_cities.city_name
)

select * from crime_ext_us_cities
  );