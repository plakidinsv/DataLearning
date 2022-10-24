
  
    

  create  table "postgres"."staging_crimespread"."us_county_2019__dbt_tmp"
  as (
    with us_county_2019 as (

    select * from "postgres"."public"."us_county_2019"

),

final as (

    select 
        concat("STATEFP", "COUNTYFP") as county_fips
        , "NAME" as county_name
        , json_build_object('type', 'Polygon','geometry'
                            , ST_AsGeoJSON(ST_Transform((ST_DUMP(geometry)).geom::geometry(Polygon, 4269), 4269))::json)::text as geojson
    from us_county_2019

)

select * from final
  );
  