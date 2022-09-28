-- create crime table
CREATE TABLE IF NOT EXISTS crime(
    state_id INT NOT NULL,
    city_id INT NOT NULL,
    population INT,
    murder_and_nonnegligent_manslaughter INT,
    rape INT,
    robbery INT,
    aggravated_assault INT,
    burglary INT, 
    larceny_theft INT, 
    motor_vehicle_theft INT,
    arson int
    );