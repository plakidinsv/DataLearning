select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
        select *
        from "postgres"."dbt_test__audit"."source_not_null_raw_data_crime_ad032ba8c2b47eb539c059f7b5babc94"
    
      
    ) dbt_internal_test