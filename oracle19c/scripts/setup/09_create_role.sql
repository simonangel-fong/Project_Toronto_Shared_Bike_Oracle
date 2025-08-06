-- ============================================================================
-- Script Name : create_role.sql
-- Purpose     : Create a role for access to materialized views and data warehouse
--               in the Toronto Shared Bike Data Warehouse
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
-- Create a role for API users
-- ========================================================
CREATE ROLE roleAPIUser;

-- Grant SELECT privileges on materialized views to the role
GRANT SELECT ON dw_schema.mv_user_time TO roleAPIUser;
GRANT SELECT ON dw_schema.mv_user_station TO roleAPIUser;
GRANT SELECT ON dw_schema.mv_station_count TO roleAPIUser;
GRANT SELECT ON dw_schema.mv_bike_count TO roleAPIUser;

GRANT connect TO roleAPIUser;

-- ========================================================
-- Create a role for data analysis
-- ========================================================
CREATE ROLE roleDataAnalysis;

-- Grant SELECT privileges on data warehouse to the role
GRANT SELECT ON dw_schema.fact_trip TO roleDataAnalysis;
GRANT SELECT ON dw_schema.dim_time TO roleDataAnalysis;
GRANT SELECT ON dw_schema.dim_station TO roleDataAnalysis;
GRANT SELECT ON dw_schema.dim_bike TO roleDataAnalysis;
GRANT SELECT ON dw_schema.dim_user_type TO roleDataAnalysis;

-- Grant SELECT privileges on materialized views to the role
GRANT SELECT ON dw_schema.mv_user_time TO roleDataAnalysis;
GRANT SELECT ON dw_schema.mv_user_station TO roleDataAnalysis;
GRANT SELECT ON dw_schema.mv_station_count TO roleDataAnalysis;
GRANT SELECT ON dw_schema.mv_bike_count TO roleDataAnalysis;

GRANT connect TO roleDataAnalysis;

-- ========================================================
-- Create a role for data engineer
-- ========================================================
CREATE ROLE roleDataEngineer;

GRANT SELECT, INSERT, UPDATE, DELETE ON dw_schema.staging_trip TO roleDataEngineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dw_schema.fact_trip TO roleDataEngineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dw_schema.dim_time TO roleDataEngineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dw_schema.dim_station TO roleDataEngineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dw_schema.dim_bike TO roleDataEngineer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dw_schema.dim_user_type TO roleDataEngineer;

GRANT CREATE MATERIALIZED VIEW TO roleDataEngineer;
GRANT DROP ANY MATERIALIZED VIEW TO roleDataEngineer;
GRANT ALTER ANY MATERIALIZED VIEW TO roleDataEngineer;

GRANT connect, resource TO roleDataEngineer;

-- ========================================================
-- Confirm
-- ========================================================
SELECT 
    role
FROM dba_roles
WHERE role IN ('ROLEAPIUSER','ROLEDATAANALYSIS', 'ROLEDATAENGINEER');
