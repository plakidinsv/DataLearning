
  create view "postgres"."staging_crimespread"."county_fips__dbt_tmp" as (
    with geo_county_2019 as (
    select * from "postgres"."staging_crimespread"."stg_us_county_2019"
),
us_cities as (
    select * from "postgres"."staging_crimespread"."stg_us_cities"
),
county_fips as (
    select 
            us_cities.state_name
            , us_cities.city_name
            , us_cities.county_name
            , us_cities.county_fips
            , geo_county_2019.geojson
    from geo_county_2019
    left join us_cities
    using(county_fips)
);
  );