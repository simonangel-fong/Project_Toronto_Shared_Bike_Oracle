-- ============================================================================
-- Script Name : 01_extract.sql
-- Purpose     : Perform the Extraction step in the ELT process by loading data 
--               from an external table into a staging table in the Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with access to the toronto_shared_bike PDB and dw_schema
-- Notes       : Ensure that the external file is accessible through the directory `dir_target`
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

-- Confirm
SELECT
    directory_name
    , directory_path
FROM dba_directories
WHERE directory_name = 'DATA_DIR';

-- ============================================================================
-- Confirm external table access by showing a sample row)
-- ============================================================================
SELECT *
FROM dw_schema.external_ridership
FETCH FIRST 2 ROWS ONLY;

-- ============================================================================
-- Truncate the staging table before loading new data
-- ============================================================================
TRUNCATE TABLE dw_schema.staging_trip;

-- ============================================================================
-- Extract data from the external table to the staging table
-- ============================================================================

INSERT /*+ APPEND */ INTO dw_schema.staging_trip
SELECT *
FROM dw_schema.external_ridership;

-- Commit the inserted data
COMMIT;

-- ============================================================================
-- Confirm data was extracted to staging
-- ============================================================================
SELECT COUNT(*)
FROM dw_schema.staging_trip
ORDER BY start_time;

SELECT *
FROM dw_schema.staging_trip
FETCH FIRST 2 ROWS ONLY;