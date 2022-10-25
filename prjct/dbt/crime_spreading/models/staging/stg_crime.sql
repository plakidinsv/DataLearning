with source as (
    select * from {{ source('raw_data', 'crime') }}
),
final as (
    select 
        lower(state) as state_name
        , lower(regexp_replace(city, ',', '', 'g')) as city_name
        , coalesce(population, 0) as population
        , murder_and_nonnegligent_manslaughter
        , coalesce(forcible_rape, 0) as forcible_rape
        , robbery
        , coalesce(aggravated_assault, 0) as aggravated_assault
        , coalesce(burglary, 0) as burglary
        , coalesce(larceny_theft, 0) as larceny_theft
        , coalesce(motor_vehicle_theft, 0) as motor_vehicle_theft
        , coalesce(arson, 0) as arson
        , year
    from source
    where city is not null
)
select * from final