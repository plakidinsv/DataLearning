select state, city, population, violent_crime, property_crime, year
from "postgres"."dbt_crimespread"."crime"
where state = 'CALIFORNIA'