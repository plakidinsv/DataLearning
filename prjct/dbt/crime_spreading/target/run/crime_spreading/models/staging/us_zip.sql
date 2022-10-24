
  
    

  create  table "postgres"."staging_crimespread"."us_zip__dbt_tmp"
  as (
    with us_zip as(

    select * from "postgres"."public"."us_zip"

),

final as (

    select * from us_zip

)

select * from final
  );
  