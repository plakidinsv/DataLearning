with crime as (

    select * from "postgres"."public"."crime"

),

final as (
    select * from crime
)

select * from final