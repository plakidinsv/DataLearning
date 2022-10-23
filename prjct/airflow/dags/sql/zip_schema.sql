CREATE TABLE IF NOT EXISTS us_zip(
    zip INT
    , lat DECIMAL
    , lng DECIMAL
    , city VARCHAR(50)
    , state_id VARCHAR(5)
    , state_name VARCHAR(100)
    , zcta VARCHAR(60)
    , parent_zcta BOOLEAN
    , population INT
    , density DECIMAL
    , county_fips INT
    , county_name VARCHAR(100)
    , county_weights VARCHAR(100)
    , county_names_all VARCHAR(100)
    , county_fips_all VARCHAR(100)
    , imprecise BOOLEAN
    , military BOOLEAN
    , timezone VARCHAR(60)
    );