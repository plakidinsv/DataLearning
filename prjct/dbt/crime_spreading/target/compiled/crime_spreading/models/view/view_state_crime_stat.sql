with crime as (
    select * from "postgres"."staging_crimespread"."stg_crime"
),
aggregate_stat_by_state as (
    select 
            state_name
            , sum(population) as population
            , sum(murder_and_nonnegligent_manslaughter) as murder_and_nonnegligent_manslaughter
            , sum(forcible_rape) as forcible_rape
            , sum(robbery) as robbery
            , sum(aggravated_assault) as aggravated_assault
            , sum(burglary) as burglary
            , sum(larceny_theft) as larceny_theft
            , sum(motor_vehicle_theft) as motor_vehicle_theft
            , sum(arson) as arson
            , max(year) as year
    from crime
    group by state_name
)
select * from aggregate_stat_by_state