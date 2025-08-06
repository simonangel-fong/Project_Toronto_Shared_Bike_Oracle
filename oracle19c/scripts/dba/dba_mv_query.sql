
-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;
SHOW con_name;
SHOW user;

-- MV LOG
SELECT 
    log_owner,
    master AS table_name,
    log_table,
    rowids,
    sequence,
    include_new_values
FROM dba_mview_logs
WHERE log_owner = 'dw_schema'
ORDER BY master;

-- MV info
SELECT 
    mview_name,
    owner,
    refresh_method,
    refresh_mode,
    fast_refreshable,
    build_mode
FROM dba_mviews
WHERE owner = 'dw_schema'
ORDER BY mview_name;



SELECT 
    index_name,
    index_type,
    table_name,
    uniqueness,
    tablespace_name,
    partitioned
FROM dba_indexes
WHERE owner = 'dw_schema'
AND table_name IN ('MV_TRIP_TIME', 'MV_DURATION_TIME', 'MV_TRIP_STATION', 'MV_USER_TYPE')
ORDER BY table_name, index_name;

