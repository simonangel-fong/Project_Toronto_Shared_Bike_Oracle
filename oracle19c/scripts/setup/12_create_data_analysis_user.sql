-- ============================================================================
-- Script Name : create_data_analysis_user.sql
-- Purpose     : Create users for data analysis access to materialized views
--               and data warehouse in the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with administrative privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the dw_schema and materialized views are created before running
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

-- ========================================================
-- Create user for data analysis
-- ========================================================
-- Create the data analyst with a secure password
CREATE USER dataAnalyst IDENTIFIED BY "SecurePassword!23";

-- Grant session creation and the data analyst role to the user
GRANT create session, roleDataAnalysis TO dataAnalyst;
--GRANT EXP_FULL_DATABASE, IMP_FULL_DATABASE TO dataEngineer;

-- ========================================================
-- Confirm
-- ========================================================
SELECT 
    username
    , account_status
FROM dba_users
WHERE username IN ('DATAANALYST');
