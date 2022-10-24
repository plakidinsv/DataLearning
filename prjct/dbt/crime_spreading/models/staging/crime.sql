
with crime as (

    select * from {{ source('raw_data', 'crime') }}

),

final as (
    select * from crime
)

select * from final