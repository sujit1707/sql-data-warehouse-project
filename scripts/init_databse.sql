-- =====================================================
-- Initialize Data Warehouse
-- Drops and recreates database and schemas
-- WARNING: This deletes the database completely
-- =====================================================

-- Run this while connected to 'postgres'


-- check database name
SELECT datname FROM pg_database;

-- if other users are using the database it won't be dropped
-- check users currently using the database
SELECT pid, datname, usename, application_name
FROM pg_stat_activity
WHERE datname = 'DataWarehouse';

-- terminate all connections to the database
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'DataWarehouse'
  AND pid <> pg_backend_pid();
drop database if exists "DataWarehouse";

-- drop database 
drop DATABASE if EXISTS "DataWarehouse";
-- create database
CREATE DATABASE datawarehouse;

-- switch conection from postgres database to datawarehouse database
-- create schemas
create schema bronze;
create schema silver;
create schema gold;

-- check schemas existence
select schema_name 
from information_schema.schemata
where schema_name in ('bronze','silver','gold');