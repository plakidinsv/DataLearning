select state, city, population, violent_crime, property_crime, year
from {{ ref('crime') }}
where state = 'CALIFORNIA'