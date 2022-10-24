with us_zip as(

    select * from {{ source('raw_data', 'us_zip') }}

),

final as (

    select * from us_zip

)

select * from final