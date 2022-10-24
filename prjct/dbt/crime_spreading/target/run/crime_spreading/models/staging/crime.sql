
  
    

  create  table "postgres"."staging_crimespread"."crime__dbt_tmp"
  as (
    with crime as (

    select * from "postgres"."public"."crime"

),

final as (
    select * from crime
)

select * from final
  );
  