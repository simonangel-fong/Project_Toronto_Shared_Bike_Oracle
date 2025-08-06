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

-- Stores table-level metadata.
CREATE TABLE dw_schema.metadata_table (
    table_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY
    , table_name      VARCHAR2(50) NOT NULL,
    table_type      VARCHAR2(10) CHECK (table_type IN ('FACT', 'DIM')),
    table_comment   VARCHAR2(4000),
    created_date    DATE DEFAULT SYSDATE
);

-- Stores column-level metadata.
CREATE TABLE dw_schema.metadata_column (
    column_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name      VARCHAR2(50) NOT NULL,
    column_name     VARCHAR2(50) NOT NULL,
    data_type       VARCHAR2(50),
    nullable        VARCHAR2(1) CHECK (nullable IN ('Y', 'N')),
    column_comment  VARCHAR2(4000),
    column_order    NUMBER,
    created_date    DATE DEFAULT SYSDATE
);


-- ETL Job Definitions
CREATE TABLE etl_metadata_job (
    job_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    job_name      VARCHAR2(100),
    job_type      VARCHAR2(20),
    source_name   VARCHAR2(100),
    target_name   VARCHAR2(100),
    schedule      VARCHAR2(50),
    owner         VARCHAR2(100),
    active_flag   CHAR(1) CHECK (active_flag IN ('Y','N')),
    created_date  DATE DEFAULT SYSDATE
);


-- ETL Job Runs
CREATE TABLE etl_metadata_run (
    run_id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    job_name       VARCHAR2(100),
    start_time     DATE,
    end_time       DATE,
    status         VARCHAR2(20),
    rows_processed NUMBER,
    error_message  VARCHAR2(4000),
    triggered_by   VARCHAR2(50)
);


-- Source-to-Target Mappings
CREATE TABLE etl_metadata_mapping (
    mapping_id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_system      VARCHAR2(100),
    source_table       VARCHAR2(100),
    source_column      VARCHAR2(100),
    transformation     VARCHAR2(1000),
    target_table       VARCHAR2(100),
    target_column      VARCHAR2(100),
    load_type          VARCHAR2(20)
);
