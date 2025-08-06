-- ============================================================================
-- Script Name : create_tbsp.sql
-- Purpose     : Create tablespaces for fact, dimension, index, staging, and materialized view storage
--               in the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with administrative privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the PDB is created and open before running this script
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Exit on error
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER=toronto_shared_bike;
SHOW con_name;
SHOW user;

-- Create FACT_TBSP tablespace for storing fact tables with a 32K block size
CREATE TABLESPACE FACT_TBSP
DATAFILE 
    '/opt/oracle/oradata/ORCLCDB/TORONTO_SHARED_BIKE/fact_tbsp01.dbf' SIZE 100M AUTOEXTEND ON NEXT 1G MAXSIZE 50G
    -- , '/opt/oracle/oradata/ORCLCDB/TORONTO_SHARED_BIKE/fact_tbsp02.dbf' SIZE 100M AUTOEXTEND ON NEXT 1G MAXSIZE 50G
BLOCKSIZE 32K
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO
LOGGING
ONLINE;

-- Create DIM_TBSP tablespace for storing dimension tables with an 8K block size
CREATE TABLESPACE DIM_TBSP
DATAFILE 
    '/opt/oracle/oradata/ORCLCDB/TORONTO_SHARED_BIKE/dim_tbsp01.dbf' SIZE 50M AUTOEXTEND ON NEXT 25M MAXSIZE 5G
    -- , '/opt/oracle/oradata/ORCLCDB/TORONTO_SHARED_BIKE/dim_tbsp02.dbf' SIZE 50M AUTOEXTEND ON NEXT 25M MAXSIZE 5G
BLOCKSIZE 8K     
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO
LOGGING
ONLINE;  

-- Create INDEX_TBSP tablespace for storing indexes with an 8K block size
CREATE TABLESPACE INDEX_TBSP
DATAFILE 
    '/opt/oracle/oradata/ORCLCDB/TORONTO_SHARED_BIKE/index_tbsp01.dbf' SIZE 50M AUTOEXTEND ON NEXT 25M MAXSIZE 2G
    -- , '/opt/oracle/oradata/ORCLCDB/TORONTO_SHARED_BIKE/index_tbsp02.dbf' SIZE 50M AUTOEXTEND ON NEXT 25M MAXSIZE 2G
BLOCKSIZE 8K 
EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
SEGMENT SPACE MANAGEMENT AUTO 
LOGGING 
ONLINE; 
  
-- Create STAGING_TBSP tablespace for storing staging tables with an 8K block size
CREATE TABLESPACE STAGING_TBSP
DATAFILE 
    '/opt/oracle/oradata/ORCLCDB/TORONTO_SHARED_BIKE/stage01.dbf' SIZE 1G AUTOEXTEND ON NEXT 500M MAXSIZE 10G
    -- , '/opt/oracle/oradata/ORCLCDB/TORONTO_SHARED_BIKE/stage02.dbf' SIZE 1G AUTOEXTEND ON NEXT 500M MAXSIZE 10G
BLOCKSIZE 8K 
EXTENT MANAGEMENT LOCAL AUTOALLOCATE 
SEGMENT SPACE MANAGEMENT AUTO 
LOGGING 
ONLINE;

-- Create MV_TBSP tablespace for storing materialized views
CREATE TABLESPACE MV_TBSP
DATAFILE 
    '/opt/oracle/oradata/ORCLCDB/TORONTO_SHARED_BIKE/MV_TBSP01.dbf' SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE 5G
    -- , '/opt/oracle/oradata/ORCLCDB/TORONTO_SHARED_BIKE/MV_TBSP02.dbf' SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE 5G
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO
LOGGING 
ONLINE;

-- Confirm the creation of tablespaces by listing those with names ending in '_TBSP'
SELECT 
    tablespace_name
    , block_size
    , status
FROM DBA_tablespaces
WHERE tablespace_name LIKE '%_TBSP';
