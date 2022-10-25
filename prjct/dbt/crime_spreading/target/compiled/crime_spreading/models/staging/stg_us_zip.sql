with source as(
    select * from "postgres"."public"."us_zip"
),
final as (
    select * from source
)
select * from final