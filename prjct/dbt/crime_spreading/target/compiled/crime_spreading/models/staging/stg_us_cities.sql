with source as (
    select * from "postgres"."seed_data"."uscities"
),
final as (
    select
        lower(city) as city_name
        , lower(state_name) as state_name
        , lower(county_name) as county_name
        , county_fips::text
    from source
)
select * from final