CREATE DATABASE geodata;
create user postgres with encrypted password 'postgres';
grant all privileges on database geodata to postgres;
CREATE EXTENSION postgis;