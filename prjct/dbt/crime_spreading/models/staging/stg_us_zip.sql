with source as(
    select * from {{ source('raw_data', 'us_zip') }}
),
final as (
    select * from source
)
select * from final