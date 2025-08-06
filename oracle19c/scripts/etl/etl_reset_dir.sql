-- ============================================================================
-- Script Name : 00_reset_dir.sql
-- Purpose     : Set the directory object for staging data for a specific year
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a privileged user with access to the toronto_shared_bike PDB
-- Notes       : Assumes the procedure `update_directory_for_year` exists in the current schema
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

-- Call the procedure to update the directory object for the given year
BEGIN
    update_directory_for_year(2019);
END;
/

-- Confirm
SELECT
    directory_name
    , directory_path
FROM dba_directories
WHERE directory_name = 'DATA_DIR';
