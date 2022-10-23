
  
    

  create  table "postgres"."dbt_crimespread"."stg_crime__dbt_tmp"
  as (
    select "state",
  "city",
  "population",
  "murder_and_nonnegligent_manslaughter",
  "forcible_rape",
  "robbery",
  "aggravated_assault",
  "burglary",
  "larceny_theft",
  "motor_vehicle_theft",
  "arson",
  "year"
from "postgres"."dbt_crimespread"."crime"
  );
  