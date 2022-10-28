with source as (
    select * from {{ ref('uscities') }}
),
final as (
    select
        regexp_replace(lower(btrim(city)), 'st\.', 'saint') as city_name
        , lower(btrim(state_name)) as state_name
        , lower(btrim(county_name)) as county_name
        , county_fips::text
        , population
    from source
)
select * from final