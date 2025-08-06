-- ============================================================================
-- Script Name : enable_archivelog.sql
-- Purpose     : Enable ARCHIVELOG mode at the Container Database (CDB) level
-- Author      : Wenhao Fang
-- Date        : 2025-05-03
-- User        : Execute as SYSDBA
-- Notes       : Ensure that the FRA (Fast Recovery Area) is properly configured.
-- ============================================================================

-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Exit on error
WHENEVER SQLERROR EXIT SQL.SQLCODE;

ALTER SESSION SET CONTAINER = CDB$ROOT;

-- ============================================================================
-- Configure Archive log mode
-- ============================================================================
-- -- Set FRA configuration before enabling ARCHIVELOG
-- ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 100G SCOPE=BOTH;
-- ALTER SYSTEM SET DB_RECOVERY_FILE_DEST = '/opt/oracle/fast_recovery_area' SCOPE=BOTH;

-- -- Confirm FRA settings
-- SHOW PARAMETER db_recovery_file_dest;
-- SHOW PARAMETER db_recovery_file_dest_size;

-- -- Shutdown
-- SHUTDOWN IMMEDIATE;

-- -- Start CDB in MOUNT mode
-- STARTUP MOUNT;

-- ALTER SESSION SET CONTAINER = CDB$ROOT;

-- -- Enable ARCHIVELOG mode
-- ALTER DATABASE ARCHIVELOG;

-- -- Open the CDB
-- ALTER DATABASE OPEN;

-- -- Confirm
-- ARCHIVE LOG LIST;

---- Add additional log member
--ALTER DATABASE ADD LOGFILE MEMBER 
--  '/opt/oracle/oradata/ORCLCDB/redo01b.log' TO GROUP 1;

-- ============================================================================
-- Configure Redo log
-- ============================================================================
-- Add additional log group
ALTER DATABASE 
ADD LOGFILE GROUP 4 (
    '/opt/oracle/oradata/ORCLCDB/redo04a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 5 (
    '/opt/oracle/oradata/ORCLCDB/redo05a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 6 (
    '/opt/oracle/oradata/ORCLCDB/redo06a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 7 (
    '/opt/oracle/oradata/ORCLCDB/redo07a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 8 (
    '/opt/oracle/oradata/ORCLCDB/redo08a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 9 (
    '/opt/oracle/oradata/ORCLCDB/redo09a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 10 (
    '/opt/oracle/oradata/ORCLCDB/redo10a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 11 (
    '/opt/oracle/oradata/ORCLCDB/redo11a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 12 (
    '/opt/oracle/oradata/ORCLCDB/redo12a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 13 (
    '/opt/oracle/oradata/ORCLCDB/redo13a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 14 (
    '/opt/oracle/oradata/ORCLCDB/redo14a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 15 (
    '/opt/oracle/oradata/ORCLCDB/redo15a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 16 (
    '/opt/oracle/oradata/ORCLCDB/redo16a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 17 (
    '/opt/oracle/oradata/ORCLCDB/redo17a.log'
)
SIZE 400M;

ALTER DATABASE 
ADD LOGFILE GROUP 18 (
    '/opt/oracle/oradata/ORCLCDB/redo18a.log'
)
SIZE 400M;

-- confirm log group
  SELECT 
    GROUP#
    , THREAD#
    , SEQUENCE#
    , BYTES / 1024 / 1024 AS SIZE_MB
    , MEMBERS
    , STATUS
    , ARCHIVED
FROM 
    V$LOG
ORDER BY GROUP#;

-- confirm log file
SELECT 
    GROUP#
    , MEMBER
    , TYPE
    , IS_RECOVERY_DEST_FILE
    , STATUS
FROM 
    V$LOGFILE
ORDER BY GROUP#, MEMBER;