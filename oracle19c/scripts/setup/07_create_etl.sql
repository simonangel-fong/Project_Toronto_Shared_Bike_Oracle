-- ============================================================================
-- Script Name : create_etl.sql
-- Purpose     : Create directory, external table, and staging table for the Extraction phase
--               of the ELT process in the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with administrative privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the dw_schema and STAGING_TBSP tablespace are created before running
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Exit on error
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

-- Create a directory object pointing to the data source location
CREATE OR REPLACE DIRECTORY data_dir 
AS '/data/2019';

-- Grant read permissions on the directory to dw_schema
GRANT READ ON DIRECTORY data_dir TO dw_schema;

-- Create the external table for accessing ridership data from CSV files
CREATE TABLE dw_schema.external_ridership (
    trip_id                 VARCHAR2(15)    -- Trip identifier
    , trip_duration         VARCHAR2(15)    -- Duration of the trip
    , start_time            VARCHAR2(50)    -- Trip start timestamp
    , start_station_id      VARCHAR2(15)    -- Start station identifier
    , start_station_name    VARCHAR2(100)   -- Start station name
    , end_time              VARCHAR2(50)    -- Trip end timestamp
    , end_station_id        VARCHAR2(15)    -- End station identifier
    , end_station_name      VARCHAR2(100)   -- End station name
    , bike_id               VARCHAR2(15)    -- Bike identifier
    , user_type             VARCHAR2(50)    -- Type of user
    , model                 VARCHAR2(50)    -- Bike model
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE SKIP 1
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
        (
            trip_id
            , trip_duration
            , start_station_id
            , start_time CHAR(50)
            , start_station_name
            , end_station_id
            , end_time CHAR(50)
            , end_station_name
            , bike_id
            , user_type
            , model
        )
    )
    LOCATION ('Ridership*.csv')  -- Match all CSV files starting with 'Ridership'
)
parallel 5
REJECT LIMIT UNLIMITED;

-- Grant unlimited quota on STAGING_TBSP to dw_schema
--ALTER USER dw_schema QUOTA UNLIMITED ON STAGING_TBSP;

-- Create the staging table for temporary storage of extracted data
CREATE TABLE dw_schema.staging_trip (
  trip_id               VARCHAR2(15)    -- Trip identifier
  , trip_duration       VARCHAR2(15)    -- Duration of the trip
  , start_time          VARCHAR2(50)    -- Trip start timestamp
  , start_station_id    VARCHAR2(15)    -- Start station identifier
  , start_station_name  VARCHAR2(100)   -- Start station name
  , end_time            VARCHAR2(50)    -- Trip end timestamp
  , end_station_id      VARCHAR2(15)    -- End station identifier
  , end_station_name    VARCHAR2(100)   -- End station name
  , bike_id             VARCHAR2(15)    -- Bike identifier
  , user_type           VARCHAR2(50)    -- Type of user
  , model               VARCHAR2(50)    -- Bike model
)
TABLESPACE STAGING_TBSP
NOLOGGING;

-- Confirm
SELECT
    directory_name
    , directory_path
FROM dba_directories
WHERE directory_name = 'DATA_DIR';

SELECT 
    table_name
    , owner
FROM DBA_TABLES
WHERE owner = 'dw_schema'
AND table_name IN ( 'EXTERNAL_RIDERSHIP', 'STAGING_TRIP');

-- Create or replace the procedure to update the directory for a given year
--DROP PROCEDURE UPDATE_DIRECTORY_FOR_YEAR;
CREATE OR REPLACE PROCEDURE UPDATE_DIRECTORY_FOR_YEAR(p_year IN VARCHAR2) IS
    v_path VARCHAR2(1000);      -- Variable to store the directory path
    sql_stmt VARCHAR2(1000);    -- Variable to store dynamic SQL statements
BEGIN
    -- Construct the directory path based on the input year
    v_path := '/data/' || p_year;

    -- Create or replace the directory object
    sql_stmt := 'CREATE OR REPLACE DIRECTORY data_dir AS ''' || v_path || '''';
    EXECUTE IMMEDIATE sql_stmt;

    -- Grant read privilege on the directory to dw_schema
    sql_stmt := 'GRANT READ ON DIRECTORY data_dir TO dw_schema';
    EXECUTE IMMEDIATE sql_stmt;

    -- Output confirmation of directory update
    DBMS_OUTPUT.PUT_LINE('Directory updated to: ' || v_path);
END;
/
-- Confirm
SELECT
    object_name
    , object_type 
    , owner
FROM dba_procedures
WHERE object_name = 'UPDATE_DIRECTORY_FOR_YEAR';