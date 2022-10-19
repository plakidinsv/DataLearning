-- create crime table
CREATE TABLE IF NOT EXISTS crime(
    state VARCHAR(30),
    city VARCHAR(30),
    population INT,
    violent_crime INT,
    murder_and_nonnegligent_manslaughter INT,
    forcible_rape INT,
    robbery INT,
    aggravated_assault INT,
    property_crime INT,
    burglary INT, 
    larceny_theft INT, 
    motor_vehicle_theft INT,
    arson int,
    year date
    );