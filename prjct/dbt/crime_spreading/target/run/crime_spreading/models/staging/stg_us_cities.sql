
  
    

  create  table "postgres"."staging_crimespread"."stg_us_cities__dbt_tmp"
  as (
    with source as (
    select * from "postgres"."seed_data"."uscities"
),
final as (
    select
        regexp_replace(lower(btrim(city)), 'st\.', 'saint') as city_name
        , lower(btrim(state_name)) as state_name
        , lower(btrim(county_name)) as county_name
        , county_fips::text
        , population
    from source
)
select * from final
  );
  