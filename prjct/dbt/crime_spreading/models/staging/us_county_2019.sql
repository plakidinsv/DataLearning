with us_county_2019 as (

    select * from {{ source('raw_data', 'us_county_2019') }}

),

final as (

    select * from us_county_2019

)

select * from final