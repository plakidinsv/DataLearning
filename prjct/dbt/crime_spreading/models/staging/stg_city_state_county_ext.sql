with source1 as (
    select * from {{ ref('cities_extended_202210242353') }}
),
source2 as (
    select * from {{ ref('states_202210250008') }}
),
final as (
    select  lower(s2.state) as state_name
            , lower(s1.county) as county_name
            , lower(s1.city) as city_name
    from source1 as s1
    join source2 as s2
    using (state_code)
    group by s2.state, s1.county, s1.city
)
select * from final