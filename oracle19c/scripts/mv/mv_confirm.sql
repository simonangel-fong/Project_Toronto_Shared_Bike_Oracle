-- ============================================================================
-- Script Name : mv_confirm.sql
-- Purpose     : Query materialized views to retrieve top records for analysis
--               and reporting purposes
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Ensure materialized views are refreshed before running this script
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

-- mv_user_time materialized view
SELECT 
    dim_year
    , dim_month
    , dim_hour
    , dim_user
    , trip_count
    , duration_sum
    , duration_avg    
FROM dw_schema.mv_user_time
ORDER BY 
    dim_year
    , dim_month
    , dim_hour
    , dim_user
;

-- Query mv_user_station materialized view
SELECT 
    dim_year
    , dim_user
    , dim_station
    , trip_count
FROM dw_schema.mv_user_station
ORDER BY 
    dim_year
    , dim_user
    , trip_count DESC
;
