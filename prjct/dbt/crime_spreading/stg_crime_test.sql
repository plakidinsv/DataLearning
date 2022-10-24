select {{ dbt_utils.star(from=ref('crime'), except=['violent_crime', 'property_crime']) }}
from {{ ref('crime') }}