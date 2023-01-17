
  
    

  create  table "postgres"."staging_crimespread"."stg_us_state_2019__dbt_tmp"
  as (
    with source as (
    select * from "postgres"."public"."us_state_2019"
),
final as (
    select 
        btrim(lower("NAME")) as state_name
        , json_build_object('type', 'Polygon','geometry'
                            , ST_AsGeoJSON(ST_Transform((ST_DUMP(geometry)).geom::geometry(Polygon, 4269), 4269))::json)::text as geojson
    from source
)
select * from final
  );
  