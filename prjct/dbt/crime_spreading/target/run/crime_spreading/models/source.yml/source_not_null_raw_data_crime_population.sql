select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select population
from "postgres"."public"."crime"
where population is null



      
    ) dbt_internal_test