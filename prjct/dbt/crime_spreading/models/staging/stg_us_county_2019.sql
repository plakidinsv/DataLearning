with source as (

    select * from {{ source('raw_data', 'us_county_2019') }}

),

final as (

    select 
        concat("STATEFP", "COUNTYFP") as county_fips
        , lower("NAME") as county_name
        , json_build_object('type', 'Polygon','geometry'
                            , ST_AsGeoJSON(ST_Transform((ST_DUMP(geometry)).geom::geometry(Polygon, 4269), 4269))::json)::text as geojson
    from source

)

select * from final