
  
    

  create  table "postgres"."dbt_crimespread"."crime__dbt_tmp"
  as (
    select * from "postgres"."public"."crime"
  );
  