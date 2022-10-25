
  
    

  create  table "postgres"."staging_crimespread"."stg_states__dbt_tmp"
  as (
    with source as (
    
    select * from "postgres"."seed_data"."states_202210250008"

),

final as (

    select * from source

)

select * from final
  );
  