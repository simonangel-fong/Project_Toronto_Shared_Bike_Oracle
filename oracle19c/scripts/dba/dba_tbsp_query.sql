-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;

-- tbsp info
SELECT 
    tablespace_name,
    block_size,
    status,
    extent_management,
    allocation_type,
    segment_space_management,
    logging
FROM dba_tablespaces
WHERE tablespace_name IN ('FACT_TBSP', 'DIM_TBSP', 'INDEX_TBSP', 'STAGING_TBSP', 'MV_TBSP')
ORDER BY tablespace_name;

-- tbsp file
SELECT 
    tablespace_name,
    file_name,
    bytes / 1024 / 1024 AS size_mb,
    autoextensible,
    increment_by * (SELECT block_size FROM dba_tablespaces WHERE tablespace_name = df.tablespace_name) / 1024 / 1024 AS increment_mb,
    maxbytes / 1024 / 1024 AS maxsize_mb
FROM dba_data_files df
WHERE tablespace_name IN ('FACT_TBSP', 'DIM_TBSP', 'INDEX_TBSP', 'STAGING_TBSP', 'MV_TBSP')
ORDER BY tablespace_name, file_name;

-- free space per tbsp
SELECT 
    tablespace_name,
    SUM(bytes) / 1024 / 1024 AS free_space_mb
FROM dba_free_space
WHERE tablespace_name IN ('FACT_TBSP', 'DIM_TBSP', 'INDEX_TBSP', 'STAGING_TBSP', 'MV_TBSP')
GROUP BY tablespace_name
ORDER BY tablespace_name;