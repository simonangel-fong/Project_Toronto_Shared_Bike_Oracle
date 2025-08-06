
-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
ALTER SESSION SET CONTAINER = cdb$root;

SHOW con_name;
SHOW user;

ARCHIVE LOG LIST;

-- archived log
SELECT 
    GROUP#,
    THREAD#,
    SEQUENCE#,
    BYTES / 1024 / 1024 AS SIZE_MB,
    MEMBERS,
    STATUS,
    ARCHIVED
FROM 
    V$LOG
ORDER BY GROUP#;

ALTER SYSTEM CHECKPOINT;

-- log file path
SELECT 
    GROUP#,
    MEMBER,
    TYPE,
    IS_RECOVERY_DEST_FILE,
    STATUS
FROM 
    V$LOGFILE
ORDER BY GROUP#, MEMBER;

-- Total size UNDOTBS --
SELECT 
    tablespace_name
    , SUM(bytes)/1024/1024 AS size_mb
  FROM dba_data_files
  WHERE tablespace_name = 'UNDOTBS1'
GROUP BY tablespace_name;

-- Free size UNDOTBS --
SELECT tablespace_name, SUM(bytes)/1024/1024 AS free_mb
  FROM dba_free_space
  WHERE tablespace_name = 'UNDOTBS1'
GROUP BY tablespace_name;

ALTER DATABASE 
DATAFILE '/opt/oracle/oradata/ORCLCDB/TORONTO_SHARED_BIKE/undotbs01.dbf' 
AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED;
COMMIT;


-- All tablespace size info --
SELECT a.tablespace_name,
   SUM (a.bytes) / (1024 * 1024)                                total_space_MB,
   ROUND (b.free, 2)                                            Free_space_MB,
   ROUND (b.free / (SUM (a.bytes) / (1024 * 1024)) * 100, 2)    percent_free
 FROM dba_data_files a,
       (  SELECT tablespace_name, SUM (bytes) / (1024 * 1024) free
            FROM dba_free_space
        GROUP BY tablespace_name) b
   WHERE a.tablespace_name = b.tablespace_name(+)
GROUP BY a.tablespace_name, b.free;


SELECT *
FROM DBA_TABLESPACES;

SELECT 
    TABLESPACE_NAME
    , FILE_NAME
    , BYTES / 1024 / 1024 
    , STATUS
FROM DBA_DATA_FILES
ORDER BY TABLESPACE_NAME, FILE_NAME;
