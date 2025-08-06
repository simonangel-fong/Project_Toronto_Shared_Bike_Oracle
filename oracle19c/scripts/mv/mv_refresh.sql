-- ============================================================================
-- Script Name : mv_refresh.sql
-- Purpose     : Refresh materialized views in the Data Warehouse to update 
--               aggregated data for reporting and analysis
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Ensure all dimension and fact tables are populated before refreshing materialized views
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
-- Refreshing mv_user_time materialized view using complete refresh
-- ============================================================================
EXEC DBMS_MVIEW.REFRESH('dw_schema.mv_user_time', 'C');

-- ============================================================================
-- Refreshing mv_user_station materialized view using complete refresh
-- ============================================================================
EXEC DBMS_MVIEW.REFRESH('dw_schema.mv_user_station', 'C');

-- ============================================================================
-- Refreshing mv_station_count materialized view using complete refresh
-- ============================================================================
EXEC DBMS_MVIEW.REFRESH('dw_schema.mv_station_count', 'C');

-- ============================================================================
-- Refreshing mv_bike_count materialized view using complete refresh
-- ============================================================================
EXEC DBMS_MVIEW.REFRESH('dw_schema.mv_bike_count', 'C');

COMMIT;