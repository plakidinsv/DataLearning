with crime as (
    select * from "postgres"."staging_crimespread"."stg_crime"
),
city_ext as (
    select * from "postgres"."staging_crimespread"."stg_city_state_county_ext"
),
geo_county_2019 as (
    select * from "postgres"."staging_crimespread"."stg_us_county_2019"
),
us_cities as (
    select * from "postgres"."staging_crimespread"."stg_us_cities"
),
crime_city_ext_nulls as (
    select  crime.state_name
            , city_ext.county_name
            , crime.city_name
    from crime
    left join city_ext
    on crime.state_name = city_ext.state_name 
        and 
        crime.city_name = city_ext.city_name 
    where city_ext.county_name is null
),
crime_ext_us_cities as (
    select crime_city_ext_nulls.state_name as state_name
            , us_cities.county_name as county_name
            , crime_city_ext_nulls.city_name as city_name
    from crime_city_ext_nulls
    left join us_cities
    on crime_city_ext_nulls.state_name = us_cities.state_name
        and crime_city_ext_nulls.city_name = us_cities.city_name
),
red_athens as (
	select 
		(case
			when (city_name = 'athens-clarke county' and state_name ='georgia') then replace(city_name, '-', ' ')
			else city_name 
		end) as city_name
        , county_name 
		, state_name
	from crime_ext_us_cities
),
get_county as (
    select 	
		city_name 
		, state_name 
		, (case
            when county_name is null and (city_name like ('%county') and city_name not like ('%police%')) then split_part(city_name, ' ', -2)
            else county_name
           end) as county_name
from red_athens
)

select * from get_county