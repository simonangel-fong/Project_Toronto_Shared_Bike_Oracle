-- ============================================================================
-- Script Name : create_schema.sql
-- Purpose     : Create a dedicated schema (dw_schema) in the Toronto Shared Bike PDB
--               and assign necessary privileges and quotas
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with administrative privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the PDB and required tablespaces (FACT_TBSP, DIM_TBSP, INDEX_TBSP, STAGING_TBSP, MV_TBSP) are created
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

-- Create the dw_schema user with a secure password
CREATE USER dw_schema
IDENTIFIED BY "SecurePassword!23"
DEFAULT TABLESPACE FACT_TBSP
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON FACT_TBSP
QUOTA UNLIMITED ON DIM_TBSP
QUOTA UNLIMITED ON INDEX_TBSP
QUOTA UNLIMITED ON STAGING_TBSP
QUOTA UNLIMITED ON MV_TBSP;

-- Grant necessary privileges to dw_schema
GRANT CONNECT TO dw_schema;
GRANT CREATE TABLE TO dw_schema;
GRANT CREATE MATERIALIZED VIEW TO dw_schema;

-- confirm user
SELECT
    username
    , created
    , profile
    , account_status
    , default_tablespace
FROM DBA_USERS
WHERE default_tablespace = UPPER('fact_tbsp');

