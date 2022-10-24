with crime as (

    select * from "postgres"."public"."crime"

),

final as (
    select 
        lower(state) as state_name
        , lower(city) as city_name
        , population
        , murder_and_nonnegligent_manslaughter
        , forcible_rape
        , robbery
        , aggravated_assault
        , burglary
        , larceny_theft
        , motor_vehicle_theft
        , arson
        , year
    from crime
)

select * from final