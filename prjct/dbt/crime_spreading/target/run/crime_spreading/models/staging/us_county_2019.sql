
  
    

  create  table "postgres"."staging_crimespread"."us_county_2019__dbt_tmp"
  as (
    with us_county_2019 as (

    select * from "postgres"."public"."us_county_2019"

),

final as (

    select * from us_county_2019

)

select * from final
  );
  