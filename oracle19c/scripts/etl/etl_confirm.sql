-- ============================================================================
-- Script Name : 04_confirm.sql
-- Purpose     : Verify the data loaded into the dimension and fact tables
--               by counting the number of records in each table
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Run this script after the transformation and loading steps to confirm data counts
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

-- Count the number of records in the time dimension table
SELECT 
--    *
    COUNT(*)
FROM dw_schema.dim_time
ORDER BY dim_time_year DESC
FETCH FIRST 5 ROWS ONLY;

-- Count the number of records in the station dimension table
SELECT 
--    *
    COUNT(*)
FROM dw_schema.dim_station
ORDER BY dim_station_id
FETCH FIRST 5 ROWS ONLY;

-- Count the number of records in the bike dimension table
SELECT 
--    *
    COUNT(*)
FROM dw_schema.dim_bike
ORDER BY dim_bike_id DESC
FETCH FIRST 5 ROWS ONLY;

-- Count the number of records in the user type dimension table
SELECT 
    *
--    COUNT(*)
FROM dw_schema.dim_user_type;

-- Count the number of records in the trip fact table
SELECT COUNT(*)
FROM dw_schema.fact_trip;

SELECT *
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time stim
ON f.fact_trip_start_time_id = stim.dim_time_id
JOIN dw_schema.dim_time etim
ON f.fact_trip_end_time_id = etim.dim_time_id
JOIN dw_schema.dim_station stst
ON f.fact_trip_start_station_id = stst.dim_station_id 
JOIN dw_schema.dim_station enst
ON f.fact_trip_start_station_id = enst.dim_station_id
JOIN dw_schema.dim_bike bk
ON f.fact_trip_bike_id = bk.dim_bike_id
JOIN dw_schema.dim_user_type ustp
ON f.fact_trip_user_type_id = ustp.dim_user_type_id
--WHERE ROWNUM < 5
ORDER BY fact_trip_start_time_id DESC
FETCH FIRST 5 ROWS ONLY;
