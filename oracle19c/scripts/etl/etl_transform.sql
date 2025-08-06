-- ============================================================================
-- Script Name : 02_transform.sql
-- Purpose     : Clean and transform data in the staging table before loading into the Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Ensure the staging table `dw_schema.staging_trip` has data loaded before running
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

-- ============================================================================
-- Data processing: Remove rows with NULLs in Key columns
-- ============================================================================

-- Query no NULL value in key columns
SELECT 
--    *
    count(*)
FROM dw_schema.staging_trip
WHERE trip_id IS NULL
  OR trip_duration IS NULL
  OR start_time IS NULL
  OR start_station_id IS NULL
  OR end_station_id IS NULL;

-- Remove NULL value
DELETE FROM dw_schema.staging_trip
WHERE trip_id IS NULL
  OR trip_duration IS NULL
  OR start_time IS NULL
  OR start_station_id IS NULL
  OR end_station_id IS NULL;
  
COMMIT;

-- Query string "NULL" value in key columns
SELECT 
--    *
    COUNT(*)
FROM dw_schema.staging_trip
WHERE trip_id = 'NULL'
  OR trip_duration = 'NULL'
  OR start_time = 'NULL'
  OR start_station_id = 'NULL'
  OR end_station_id = 'NULL';
  
-- Remove rows where station IDs are the string "NULL"
DELETE FROM dw_schema.staging_trip
WHERE trip_id = 'NULL'
  OR trip_duration = 'NULL'
  OR start_time = 'NULL'
  OR start_station_id = 'NULL'
  OR end_station_id = 'NULL';

COMMIT;

-- ============================================================================
-- Key columns processing: Remove rows with invalid data types or formats
-- ============================================================================

-- Query invalid data type
SELECT 
--    *
    count(*)
FROM dw_schema.staging_trip
WHERE
  -- trip_id must be numeric
  NOT REGEXP_LIKE(trip_id, '^[0-9]+$')
  -- trip_duration must be a valid number
  OR NOT REGEXP_LIKE(trip_duration, '^[0-9]+(\.[0-9]+)?$')
  -- start_time must follow MM/DD/YYYY HH24:MI
  OR NOT REGEXP_LIKE(start_time, '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$')
  -- start_time must be a valid date
  OR TO_DATE(start_time, 'MM/DD/YYYY HH24:MI', 'NLS_DATE_LANGUAGE = AMERICAN') IS NULL
  -- station IDs must be numeric
  OR NOT REGEXP_LIKE(start_station_id, '^[0-9]+$')
  OR NOT REGEXP_LIKE(end_station_id, '^[0-9]+$');

-- Delete invalid data type
DELETE FROM dw_schema.staging_trip
WHERE
  -- trip_id must be numeric
  NOT REGEXP_LIKE(trip_id, '^[0-9]+$')
  -- trip_duration must be a valid number
  OR NOT REGEXP_LIKE(trip_duration, '^[0-9]+(\.[0-9]+)?$')
  -- start_time must follow MM/DD/YYYY HH24:MI
  OR NOT REGEXP_LIKE(start_time, '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$')
  -- start_time must be a valid date
  OR TO_DATE(start_time, 'MM/DD/YYYY HH24:MI', 'NLS_DATE_LANGUAGE = AMERICAN') IS NULL
  -- station IDs must be numeric
  OR NOT REGEXP_LIKE(start_station_id, '^[0-9]+$')
  OR NOT REGEXP_LIKE(end_station_id, '^[0-9]+$');

COMMIT;

-- ============================================================================
-- Key column processing (trip durations): Remove rows with non-positive value
-- ============================================================================

-- Query non posistive duration
SELECT
--    *
    COUNT(*)
FROM dw_schema.staging_trip
WHERE TO_NUMBER(trip_duration) <= 0;

-- Delete non positive duration
DELETE FROM dw_schema.staging_trip
WHERE TO_NUMBER(trip_duration) <= 0;

COMMIT;

-- ============================================================================
-- Non-critical columns processing
-- ============================================================================

-- Validate: 
SELECT 
--    *
    COUNT(*)
FROM dw_schema.staging_trip
WHERE
  -- end_time is null value
  end_time IS NULL
  --  end_time is invalid type
  OR NOT REGEXP_LIKE(end_time, '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$')
  -- end_time is invalid format
  OR TO_DATE(end_time, 'MM/DD/YYYY HH24:MI', 'NLS_DATE_LANGUAGE = AMERICAN') IS NULL;

-- Calculate end_time value
-- When 
--    end_time is null value
--    end_time is invalid type
--    end_time is invalid format
-- By
--    start_time + trip_duration
UPDATE dw_schema.staging_trip
SET end_time = TO_CHAR(
  TO_DATE(start_time, 'MM/DD/YYYY HH24:MI') + (TO_NUMBER(trip_duration) / 86400),
  'MM/DD/YYYY HH24:MI'
)
WHERE
  -- end_time is null value
  end_time IS NULL
  --  end_time is invalid type
  OR NOT REGEXP_LIKE(end_time, '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$')
  -- end_time is invalid format
  OR TO_DATE(end_time, 'MM/DD/YYYY HH24:MI', 'NLS_DATE_LANGUAGE = AMERICAN') IS NULL;

COMMIT;

-- Substitute start_station_name/end_station_name with 'UNKNOWN' value
-- confirm
SELECT 
--   *
  COUNT(*)
FROM dw_schema.staging_trip
WHERE 
    start_station_name IS NULL
    OR end_station_name IS NULL
    OR TRIM(start_station_name) = 'NULL'
    OR TRIM(end_station_name) = 'NULL';

-- When 
--    start_station_name is null value
--    end_station_name is invalid type
-- By
--    "UNKNOWN"
UPDATE dw_schema.staging_trip
SET start_station_name = 'UNKNOWN',
    end_station_name = 'UNKNOWN'
WHERE 
    start_station_name IS NULL
    OR end_station_name IS NULL
    OR TRIM(start_station_name) = 'NULL'
    OR TRIM(end_station_name) = 'NULL';

COMMIT;

-- query for user_type is null value
SELECT
--   *
  COUNT(*)
FROM dw_schema.staging_trip
WHERE user_type IS NULL;

-- Substitute missing user_type with 'UNKNOWN'
-- When
--    user_type is null value
-- By 'UNKNOWN'
UPDATE dw_schema.staging_trip
SET user_type = 'UNKNOWN'
WHERE user_type IS NULL;

COMMIT;

-- query bike_id has no 
SELECT
--    *
    COUNT(*)
FROM dw_schema.staging_trip
WHERE bike_id IS NULL
   OR (NOT REGEXP_LIKE(bike_id, '^[0-9]+$') AND bike_id != '-1');
   
-- Substitute invalid or missing bike_id with '-1'
-- When
--    bike_id is null value
--    bike_id is not in numeric type
-- By '-1'
UPDATE dw_schema.staging_trip
SET bike_id = '-1'
WHERE bike_id IS NULL
   OR (NOT REGEXP_LIKE(bike_id, '^[0-9]+$') AND bike_id != '-1');

COMMIT;

-- query for model is null value
SELECT
--    *
    COUNT(*)
FROM dw_schema.staging_trip
WHERE model IS NULL;

-- Substitute missing model with 'UNKNOWN'
-- When
--    model is null value
-- By 'UNKNOWN'
UPDATE dw_schema.staging_trip
SET model = 'UNKNOWN'
WHERE model IS NULL;

COMMIT;

-- query
SELECT
--    *
    count(*)
FROM dw_schema.staging_trip
WHERE INSTR(user_type, CHR(13)) > 0;

-- Substitue '\r' in user type
-- When 
--    user_type container '\r'(CHR(13))
-- BY ''
UPDATE dw_schema.staging_trip
SET user_type = REPLACE(user_type, CHR(13), '')
WHERE INSTR(user_type, CHR(13)) > 0;

COMMIT;

-- ============================================================================
-- Final Confirm
-- ============================================================================
SELECT *
FROM dw_schema.staging_trip
FETCH FIRST 2 ROWS ONLY;
