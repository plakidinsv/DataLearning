select 	year
		, btrim(state_name) as state_name
        , population
        , homicide
        , coalesce(rape_legacy, 0) as rape_legacy
        , coalesce(rape_revised, 0) as rape_revised
        , robbery
        , aggravated_assault
        , burglary
       	, larceny
        , motor_vehicle_theft
from "postgres"."dbt_crimespread"."host_estim_crime"
order by year, state_name