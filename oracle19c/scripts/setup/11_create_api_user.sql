-- ============================================================================
-- Script Name : create_api_user.sql
-- Purpose     : Create users for API access to materialized views
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
-- Create user for api app
-- ========================================================
-- Create the API user with a secure password
CREATE USER apiApp IDENTIFIED BY "SecurePassword!23";

-- Grant session creation and the API role to the user
GRANT create session, roleAPIUser TO apiApp;

-- ========================================================
-- Confirm
-- ========================================================
SELECT 
    username
    , account_status
FROM dba_users
WHERE username IN ('APIAPP');
