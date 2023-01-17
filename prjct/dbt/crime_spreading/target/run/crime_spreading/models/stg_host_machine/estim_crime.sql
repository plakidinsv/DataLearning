
  
    

  create  table "postgres"."dbt_crimespread"."estim_crime__dbt_tmp"
  as (
    with source as (
    select "year",
  "state_abbr",
  "state_name",
  "population",
  "violent_crime",
  "homicide",
  "rape_legacy",
  "rape_revised",
  "robbery",
  "aggravated_assault",
  "property_crime",
  "burglary",
  "larceny",
  "motor_vehicle_theft"
    from "postgres"."seed_data"."estimated_crimes_1979_2020"
)
select * from source
where state_abbr is not null and state_name is not null
  );
  