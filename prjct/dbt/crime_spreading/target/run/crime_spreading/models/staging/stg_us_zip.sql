
  
    

  create  table "postgres"."staging_crimespread"."stg_us_zip__dbt_tmp"
  as (
    with source as(
    select * from "postgres"."public"."us_zip"
),
final as (
    select * from source
)
select * from final
  );
  