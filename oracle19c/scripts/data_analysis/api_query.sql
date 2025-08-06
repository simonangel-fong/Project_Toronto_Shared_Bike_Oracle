-- ============================================================================
-- Script Name : apiquery.sql
-- Purpose     : 
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : 
-- Notes       : 
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

-- ============================================================================
-- Analysis: mv_trip_time
-- ============================================================================
SELECT *
FROM dw_schema.mv_trip_time
ORDER BY dim_year ASC, dim_month ASC, dim_hour ASC;

-- ============================================================================
-- Analysis: mv_duration_time
-- ============================================================================
SELECT *
FROM dw_schema.mv_duration_time
ORDER BY dim_year ASC, dim_month ASC, dim_hour ASC;

-- ============================================================================
-- Analysis: mv_trip_station
-- ============================================================================
SELECT *
FROM dw_schema.mv_trip_station
ORDER BY dim_year ASC, trip_count_by_start DESC;

-- ============================================================================
-- Analysis: mv_user_type
-- ============================================================================
SELECT *
FROM dw_schema.mv_user_type
ORDER BY dim_year ASC, dim_user_type_name ASC;

COMMIT;
