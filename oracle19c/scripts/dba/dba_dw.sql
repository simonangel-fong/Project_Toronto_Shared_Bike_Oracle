-- Output from the DBMS_OUTPUT to standard output
SET SERVEROUTPUT ON;
-- Allow blank lines 
SET SQLBLANKLINES ON;

-- Switch to the Toronto Shared Bike PDB
ALTER SESSION SET CONTAINER = toronto_shared_bike;

-- table
SELECT 
    table_name,
    owner,
    tablespace_name,
    partitioned
FROM dba_tables
WHERE owner = 'dw_schema'
ORDER BY table_name;

-- partition info
SELECT 
    table_name,
    partition_name,
    high_value,
    tablespace_name
FROM dba_tab_partitions
WHERE table_owner = 'dw_schema'
ORDER BY table_name, partition_name;

-- index
SELECT 
    index_name,
    index_type,
    table_name,
    uniqueness,
    tablespace_name,
    partitioned
FROM dba_indexes
WHERE owner = 'dw_schema'
ORDER BY table_name, index_name;

-- constraint info
SELECT 
    constraint_name,
    constraint_type,
    table_name,
    status,
    r_constraint_name
FROM dba_constraints
WHERE owner = 'dw_schema'
ORDER BY table_name, constraint_name;