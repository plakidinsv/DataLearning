with source as (

    select * from {{ ref('cities_extended_202210242353') }}

),

final as (

    select city
            , state_code
            , county
    from source
)

select * from final