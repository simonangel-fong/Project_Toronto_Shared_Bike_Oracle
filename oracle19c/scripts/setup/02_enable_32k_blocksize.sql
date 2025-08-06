-- ============================================================================
-- Script Name : enable_32k_blocksize.sql
-- Purpose     : Enable 32KB block size support at the Container Database (CDB) level
-- Author      : Wenhao Fang
-- Date        : 2025-05-03
-- Role        : Execute as SYSDBA
-- Notes       : 32K block size requires a dedicated buffer cache. Ensure the SPFILE is in use.
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Exit on error
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- Switch to the root container
ALTER SESSION SET CONTAINER = CDB$ROOT;
SHOW con_name;
SHOW user;

-- Set 32K block size buffer cache (applies to SPFILE only)
ALTER SYSTEM SET DB_32K_CACHE_SIZE = 256M SCOPE = SPFILE;

-- Restart the CDB for the change to take effect
SHUTDOWN IMMEDIATE;
STARTUP;

-- Confirm cache size setting
SHOW PARAMETER db_32k_cache_size;
