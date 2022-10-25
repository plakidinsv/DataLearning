with source as (
    
    select * from "postgres"."seed_data"."states_202210250008"

),

final as (

    select * from source

)

select * from final