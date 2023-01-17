with source as (
    select {{ dbt_utils.star(from=ref('estimated_crimes_1979_2020'), except=['caveats']) }}
    from {{ ref('estimated_crimes_1979_2020') }}
)
select * from source
where state_abbr is not null and state_name is not null
