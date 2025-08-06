-- ============================================================================
-- Script Name : create_dw.sql
-- Purpose     : Create dimension and fact tables for the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with appropriate privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the dw_schema and required tablespaces (FACT_TBSP, DIM_TBSP, INDEX_TBSP) are created
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

-- Create the time dimension table
CREATE TABLE dw_schema.dim_time (
  dim_time_id           DATE        NOT NULL  -- Unique time identifier (canonical date representation)
  -- dim_time_id           NUMBER(12)  NOT NULL  -- Unique time identifier (YYYYMMDDHHMI)
  -- , dim_time_timestamp  DATE        NOT NULL  -- Canonical date representation
  , dim_time_year       NUMBER(4)   NOT NULL  -- Year (e.g., 2024)
  , dim_time_quarter    NUMBER(1)   NOT NULL  -- Quarter
  , dim_time_month      NUMBER(2)   NOT NULL  -- Month
  , dim_time_day        NUMBER(2)   NOT NULL  -- Day
  , dim_time_week       NUMBER(2)   NOT NULL  -- Week
  , dim_time_weekday    NUMBER(1)   NOT NULL  -- Day of week
  , dim_time_hour       NUMBER(2)   NOT NULL  -- Hour
  , dim_time_minute     NUMBER(2)   NOT NULL  -- Minute
  , CONSTRAINT pk_dim_time  PRIMARY KEY (dim_time_id) USING INDEX TABLESPACE INDEX_TBSP   -- Primary key with B-tree index
  , CONSTRAINT chk_year     CHECK (dim_time_year BETWEEN 2000 AND 2999   )                -- Validate year (2000-2999)
  , CONSTRAINT chk_quarter  CHECK (dim_time_quarter BETWEEN 1 AND 4)                      -- Validate quarter (1-4)
  , CONSTRAINT chk_month    CHECK (dim_time_month BETWEEN 1 AND 12)                       -- Validate month (1-12)
  , CONSTRAINT chk_day      CHECK (dim_time_day BETWEEN 1 AND 31)                         -- Validate day (1-31)
  , CONSTRAINT chk_week     CHECK (dim_time_week BETWEEN 1 AND 53)                        -- Validate week (1-53)
  , CONSTRAINT chk_weekday  CHECK (dim_time_weekday BETWEEN 1 AND 7)                      -- Validate day of week
  , CONSTRAINT chk_hour     CHECK (dim_time_hour BETWEEN 0 AND 23)                        -- Validate hour (0-23)
  , CONSTRAINT chk_minute   CHECK (dim_time_minute BETWEEN 0 AND 59)                      -- Validate minute (0-59)
)
TABLESPACE DIM_TBSP;

-- -- Create B-tree index on timestamp for efficient queries
-- CREATE INDEX dw_schema.index_dim_time_date
--   ON dw_schema.dim_time (dim_time_timestamp)
--   TABLESPACE INDEX_TBSP;

-- Create composite B-tree index on year and month for time-based aggregations
CREATE INDEX dw_schema.index_dim_time_year_month
  ON dw_schema.dim_time (dim_time_year, dim_time_month)
  TABLESPACE INDEX_TBSP;

-- Create the station dimension table
CREATE TABLE dw_schema.dim_station (
  dim_station_id      NUMBER(6)       NOT NULL  -- Unique station identifier
  , dim_station_name  VARCHAR2(100)   NOT NULL  -- Station name
  , CONSTRAINT pk_dim_station PRIMARY KEY (dim_station_id) USING INDEX TABLESPACE INDEX_TBSP  -- Primary key with B-tree index
)
TABLESPACE DIM_TBSP;

-- Create B-tree index on station name for efficient lookups
CREATE INDEX dw_schema.index_dim_station_station_name
ON dw_schema.dim_station (dim_station_name)
TABLESPACE INDEX_TBSP;

-- Create the bike dimension table
CREATE TABLE dw_schema.dim_bike (
  dim_bike_id       NUMBER(6)     NOT NULL  -- Unique bike identifier
  , dim_bike_model  VARCHAR2(50)  NOT NULL  -- Bike model
  , CONSTRAINT pk_dim_bike PRIMARY KEY (dim_bike_id) USING INDEX TABLESPACE INDEX_TBSP  -- Primary key with B-tree index
)
TABLESPACE DIM_TBSP;

-- Create the user type dimension table
CREATE TABLE dw_schema.dim_user_type (
  dim_user_type_id        NUMBER(3)     GENERATED ALWAYS AS IDENTITY  -- Auto-incremented unique identifier
  , dim_user_type_name    VARCHAR2(50)  NOT NULL                      -- User type name
  , CONSTRAINT pk_dim_user_type PRIMARY KEY (dim_user_type_id) USING INDEX TABLESPACE INDEX_TBSP    -- Primary key with B-tree index
  , CONSTRAINT uk_dim_user_type_name UNIQUE (dim_user_type_name) USING INDEX TABLESPACE INDEX_TBSP  -- Unique constraint on user type name
)
TABLESPACE DIM_TBSP;

-- Create the trip fact table with range-range partitioning
CREATE TABLE dw_schema.fact_trip (
    fact_trip_id                  NUMBER(10)  GENERATED ALWAYS AS IDENTITY  -- Auto-incremented unique identifier
    , fact_trip_source_id         NUMBER(10)  NOT NULL                      -- Source trip identifier
    , fact_trip_duration          NUMBER(8)   NOT NULL                      -- Trip duration in seconds
    , fact_trip_start_time_id     DATE        NOT NULL                      -- Reference to start time dimension
    -- , fact_trip_start_time_id     NUMBER(12)  NOT NULL                      -- Reference to start time dimension
    , fact_trip_end_time_id       DATE        NOT NULL                      -- Reference to end time dimension
    -- , fact_trip_end_time_id       NUMBER(12)  NOT NULL                      -- Reference to end time dimension
    , fact_trip_start_station_id  NUMBER(6)   NOT NULL                      -- Reference to start station dimension
    , fact_trip_end_station_id    NUMBER(6)   NOT NULL                      -- Reference to end station dimension
    , fact_trip_bike_id           NUMBER(6)   NOT NULL                      -- Reference to bike dimension
    , fact_trip_user_type_id      NUMBER(3)   NOT NULL                      -- Reference to user type dimension
    , CONSTRAINT pk_fact_trip                 PRIMARY KEY (fact_trip_id)                USING INDEX TABLESPACE INDEX_TBSP
    , CONSTRAINT fk_fact_trip_start_time      FOREIGN KEY (fact_trip_start_time_id)     REFERENCES dw_schema.dim_time (dim_time_id)
    , CONSTRAINT fk_fact_trip_end_time        FOREIGN KEY (fact_trip_end_time_id)       REFERENCES dw_schema.dim_time (dim_time_id)
    , CONSTRAINT fk_fact_trip_start_station   FOREIGN KEY (fact_trip_start_station_id)  REFERENCES dw_schema.dim_station (dim_station_id)
    , CONSTRAINT fk_fact_trip_end_station     FOREIGN KEY (fact_trip_end_station_id)    REFERENCES dw_schema.dim_station (dim_station_id)
    , CONSTRAINT fk_fact_trip_bike            FOREIGN KEY (fact_trip_bike_id)           REFERENCES dw_schema.dim_bike (dim_bike_id)
    , CONSTRAINT fk_fact_trip_user_type       FOREIGN KEY (fact_trip_user_type_id)      REFERENCES dw_schema.dim_user_type (dim_user_type_id)
)
TABLESPACE FACT_TBSP
ROW STORE COMPRESS ADVANCED --allowing for faster scans and improved performance
PARTITION BY RANGE (fact_trip_start_time_id)
  SUBPARTITION BY RANGE (fact_trip_start_time_id)
  (
    PARTITION p_before_2019 VALUES LESS THAN (TO_DATE('2019-01-01', 'YYYY-MM-DD'))  -- Catch-all partition for pre-2019 data
    (
      SUBPARTITION p_before_2019_default VALUES LESS THAN (MAXVALUE) TABLESPACE FACT_TBSP
    ),
    PARTITION p_2019 VALUES LESS THAN (TO_DATE('2020-01-01', 'YYYY-MM-DD'))          -- Partition for 2019 data
    (
      SUBPARTITION p_2019_jan VALUES LESS THAN (TO_DATE('2019-02-01', 'YYYY-MM-DD')), -- Subpartition for January 2019
      SUBPARTITION p_2019_feb VALUES LESS THAN (TO_DATE('2019-03-01', 'YYYY-MM-DD')), -- Subpartition for February 2019
      SUBPARTITION p_2019_mar VALUES LESS THAN (TO_DATE('2019-04-01', 'YYYY-MM-DD')), -- Subpartition for March 2019
      SUBPARTITION p_2019_apr VALUES LESS THAN (TO_DATE('2019-05-01', 'YYYY-MM-DD')), -- Subpartition for April 2019
      SUBPARTITION p_2019_may VALUES LESS THAN (TO_DATE('2019-06-01', 'YYYY-MM-DD')), -- Subpartition for May 2019
      SUBPARTITION p_2019_jun VALUES LESS THAN (TO_DATE('2019-07-01', 'YYYY-MM-DD')), -- Subpartition for June 2019
      SUBPARTITION p_2019_jul VALUES LESS THAN (TO_DATE('2019-08-01', 'YYYY-MM-DD')), -- Subpartition for July 2019
      SUBPARTITION p_2019_aug VALUES LESS THAN (TO_DATE('2019-09-01', 'YYYY-MM-DD')), -- Subpartition for August 2019
      SUBPARTITION p_2019_sep VALUES LESS THAN (TO_DATE('2019-10-01', 'YYYY-MM-DD')), -- Subpartition for September 2019
      SUBPARTITION p_2019_oct VALUES LESS THAN (TO_DATE('2019-11-01', 'YYYY-MM-DD')), -- Subpartition for October 2019
      SUBPARTITION p_2019_nov VALUES LESS THAN (TO_DATE('2019-12-01', 'YYYY-MM-DD')), -- Subpartition for November 2019
      SUBPARTITION p_2019_dec VALUES LESS THAN (TO_DATE('2020-01-01', 'YYYY-MM-DD'))  -- Subpartition for December 2019
    ),
    PARTITION p_2020 VALUES LESS THAN (TO_DATE('2021-01-01', 'YYYY-MM-DD'))          -- Partition for 2020 data
    (
      SUBPARTITION p_2020_jan VALUES LESS THAN (TO_DATE('2020-02-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2020_feb VALUES LESS THAN (TO_DATE('2020-03-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2020_mar VALUES LESS THAN (TO_DATE('2020-04-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2020_apr VALUES LESS THAN (TO_DATE('2020-05-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2020_may VALUES LESS THAN (TO_DATE('2020-06-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2020_jun VALUES LESS THAN (TO_DATE('2020-07-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2020_jul VALUES LESS THAN (TO_DATE('2020-08-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2020_aug VALUES LESS THAN (TO_DATE('2020-09-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2020_sep VALUES LESS THAN (TO_DATE('2020-10-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2020_oct VALUES LESS THAN (TO_DATE('2020-11-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2020_nov VALUES LESS THAN (TO_DATE('2020-12-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2020_dec VALUES LESS THAN (TO_DATE('2021-01-01', 'YYYY-MM-DD'))
    ),
    PARTITION p_2021 VALUES LESS THAN (TO_DATE('2022-01-01', 'YYYY-MM-DD'))          -- Partition for 2021 data
    (
      SUBPARTITION p_2021_jan VALUES LESS THAN (TO_DATE('2021-02-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2021_feb VALUES LESS THAN (TO_DATE('2021-03-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2021_mar VALUES LESS THAN (TO_DATE('2021-04-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2021_apr VALUES LESS THAN (TO_DATE('2021-05-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2021_may VALUES LESS THAN (TO_DATE('2021-06-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2021_jun VALUES LESS THAN (TO_DATE('2021-07-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2021_jul VALUES LESS THAN (TO_DATE('2021-08-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2021_aug VALUES LESS THAN (TO_DATE('2021-09-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2021_sep VALUES LESS THAN (TO_DATE('2021-10-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2021_oct VALUES LESS THAN (TO_DATE('2021-11-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2021_nov VALUES LESS THAN (TO_DATE('2021-12-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2021_dec VALUES LESS THAN (TO_DATE('2022-01-01', 'YYYY-MM-DD'))
    ),
    PARTITION p_2022 VALUES LESS THAN (TO_DATE('2023-01-01', 'YYYY-MM-DD'))          -- Partition for 2022 data
    (
      SUBPARTITION p_2022_jan VALUES LESS THAN (TO_DATE('2022-02-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2022_feb VALUES LESS THAN (TO_DATE('2022-03-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2022_mar VALUES LESS THAN (TO_DATE('2022-04-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2022_apr VALUES LESS THAN (TO_DATE('2022-05-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2022_may VALUES LESS THAN (TO_DATE('2022-06-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2022_jun VALUES LESS THAN (TO_DATE('2022-07-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2022_jul VALUES LESS THAN (TO_DATE('2022-08-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2022_aug VALUES LESS THAN (TO_DATE('2022-09-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2022_sep VALUES LESS THAN (TO_DATE('2022-10-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2022_oct VALUES LESS THAN (TO_DATE('2022-11-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2022_nov VALUES LESS THAN (TO_DATE('2022-12-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2022_dec VALUES LESS THAN (TO_DATE('2023-01-01', 'YYYY-MM-DD'))
    ),
    PARTITION p_2023 VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD'))          -- Partition for 2023 data
    (
      SUBPARTITION p_2023_jan VALUES LESS THAN (TO_DATE('2023-02-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2023_feb VALUES LESS THAN (TO_DATE('2023-03-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2023_mar VALUES LESS THAN (TO_DATE('2023-04-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2023_apr VALUES LESS THAN (TO_DATE('2023-05-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2023_may VALUES LESS THAN (TO_DATE('2023-06-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2023_jun VALUES LESS THAN (TO_DATE('2023-07-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2023_jul VALUES LESS THAN (TO_DATE('2023-08-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2023_aug VALUES LESS THAN (TO_DATE('2023-09-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2023_sep VALUES LESS THAN (TO_DATE('2023-10-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2023_oct VALUES LESS THAN (TO_DATE('2023-11-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2023_nov VALUES LESS THAN (TO_DATE('2023-12-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2023_dec VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD'))
    ),
    PARTITION p_2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD'))          -- Partition for 2024 data
    (
      SUBPARTITION p_2024_jan VALUES LESS THAN (TO_DATE('2024-02-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2024_feb VALUES LESS THAN (TO_DATE('2024-03-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2024_mar VALUES LESS THAN (TO_DATE('2024-04-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2024_apr VALUES LESS THAN (TO_DATE('2024-05-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2024_may VALUES LESS THAN (TO_DATE('2024-06-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2024_jun VALUES LESS THAN (TO_DATE('2024-07-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2024_jul VALUES LESS THAN (TO_DATE('2024-08-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2024_aug VALUES LESS THAN (TO_DATE('2024-09-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2024_sep VALUES LESS THAN (TO_DATE('2024-10-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2024_oct VALUES LESS THAN (TO_DATE('2024-11-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2024_nov VALUES LESS THAN (TO_DATE('2024-12-01', 'YYYY-MM-DD')),
      SUBPARTITION p_2024_dec VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD'))
    ),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)                                  -- Catch-all partition for future data
    (
      SUBPARTITION p_future_default VALUES LESS THAN (MAXVALUE) TABLESPACE FACT_TBSP
    )
  );
-- PARTITION BY RANGE (fact_trip_start_time_id)
-- SUBPARTITION BY RANGE (fact_trip_start_time_id)
-- (
--   PARTITION p_before_2019 VALUES LESS THAN (201901010000),  -- Catch-all partition for pre-2019 data
--   PARTITION p_2019 VALUES LESS THAN (202000000000)          -- Partition for 2019 data
--   (
--     SUBPARTITION p_2019_jan VALUES LESS THAN (201902010000),  -- Subpartition for January 2019
--     SUBPARTITION p_2019_feb VALUES LESS THAN (201903010000),  -- Subpartition for February 2019
--     SUBPARTITION p_2019_mar VALUES LESS THAN (201904010000),  -- Subpartition for March 2019
--     SUBPARTITION p_2019_apr VALUES LESS THAN (201905010000),  -- Subpartition for April 2019
--     SUBPARTITION p_2019_may VALUES LESS THAN (201906010000),  -- Subpartition for May 2019
--     SUBPARTITION p_2019_jun VALUES LESS THAN (201907010000),  -- Subpartition for June 2019
--     SUBPARTITION p_2019_jul VALUES LESS THAN (201908010000),  -- Subpartition for July 2019
--     SUBPARTITION p_2019_aug VALUES LESS THAN (201909010000),  -- Subpartition for August 2019
--     SUBPARTITION p_2019_sep VALUES LESS THAN (201910010000),  -- Subpartition for September 2019
--     SUBPARTITION p_2019_oct VALUES LESS THAN (201911010000),  -- Subpartition for October 2019
--     SUBPARTITION p_2019_nov VALUES LESS THAN (201912010000),  -- Subpartition for November 2019
--     SUBPARTITION p_2019_dec VALUES LESS THAN (202000000000)   -- Subpartition for December 2019
--   ),
--   PARTITION p_2020 VALUES LESS THAN (202100000000)          -- Partition for 2020 data
--   (
--     SUBPARTITION p_2020_jan VALUES LESS THAN (202002010000),
--     SUBPARTITION p_2020_feb VALUES LESS THAN (202003010000),
--     SUBPARTITION p_2020_mar VALUES LESS THAN (202004010000),
--     SUBPARTITION p_2020_apr VALUES LESS THAN (202005010000),
--     SUBPARTITION p_2020_may VALUES LESS THAN (202006010000),
--     SUBPARTITION p_2020_jun VALUES LESS THAN (202007010000),
--     SUBPARTITION p_2020_jul VALUES LESS THAN (202008010000),
--     SUBPARTITION p_2020_aug VALUES LESS THAN (202009010000),
--     SUBPARTITION p_2020_sep VALUES LESS THAN (202010010000),
--     SUBPARTITION p_2020_oct VALUES LESS THAN (202011010000),
--     SUBPARTITION p_2020_nov VALUES LESS THAN (202012010000),
--     SUBPARTITION p_2020_dec VALUES LESS THAN (202100000000)
--   ),
--   PARTITION p_2021 VALUES LESS THAN (202200000000)          -- Partition for 2021 data
--   (
--     SUBPARTITION p_2021_jan VALUES LESS THAN (202102010000),
--     SUBPARTITION p_2021_feb VALUES LESS THAN (202103010000),
--     SUBPARTITION p_2021_mar VALUES LESS THAN (202104010000),
--     SUBPARTITION p_2021_apr VALUES LESS THAN (202105010000),
--     SUBPARTITION p_2021_may VALUES LESS THAN (202106010000),
--     SUBPARTITION p_2021_jun VALUES LESS THAN (202107010000),
--     SUBPARTITION p_2021_jul VALUES LESS THAN (202108010000),
--     SUBPARTITION p_2021_aug VALUES LESS THAN (202109010000),
--     SUBPARTITION p_2021_sep VALUES LESS THAN (202110010000),
--     SUBPARTITION p_2021_oct VALUES LESS THAN (202111010000),
--     SUBPARTITION p_2021_nov VALUES LESS THAN (202112010000),
--     SUBPARTITION p_2021_dec VALUES LESS THAN (202200000000)
--   ),
--   PARTITION p_2022 VALUES LESS THAN (202300000000)          -- Partition for 2022 data
--   (
--     SUBPARTITION p_2022_jan VALUES LESS THAN (202202010000),
--     SUBPARTITION p_2022_feb VALUES LESS THAN (202203010000),
--     SUBPARTITION p_2022_mar VALUES LESS THAN (202204010000),
--     SUBPARTITION p_2022_apr VALUES LESS THAN (202205010000),
--     SUBPARTITION p_2022_may VALUES LESS THAN (202206010000),
--     SUBPARTITION p_2022_jun VALUES LESS THAN (202207010000),
--     SUBPARTITION p_2022_jul VALUES LESS THAN (202208010000),
--     SUBPARTITION p_2022_aug VALUES LESS THAN (202209010000),
--     SUBPARTITION p_2022_sep VALUES LESS THAN (202210010000),
--     SUBPARTITION p_2022_oct VALUES LESS THAN (202211010000),
--     SUBPARTITION p_2022_nov VALUES LESS THAN (202212010000),
--     SUBPARTITION p_2022_dec VALUES LESS THAN (202300000000)
--   ),
--   PARTITION p_2023 VALUES LESS THAN (202400000000)          -- Partition for 2023 data
--   (
--     SUBPARTITION p_2023_jan VALUES LESS THAN (202302010000),
--     SUBPARTITION p_2023_feb VALUES LESS THAN (202303010000),
--     SUBPARTITION p_2023_mar VALUES LESS THAN (202304010000),
--     SUBPARTITION p_2023_apr VALUES LESS THAN (202305010000),
--     SUBPARTITION p_2023_may VALUES LESS THAN (202306010000),
--     SUBPARTITION p_2023_jun VALUES LESS THAN (202307010000),
--     SUBPARTITION p_2023_jul VALUES LESS THAN (202308010000),
--     SUBPARTITION p_2023_aug VALUES LESS THAN (202309010000),
--     SUBPARTITION p_2023_sep VALUES LESS THAN (202310010000),
--     SUBPARTITION p_2023_oct VALUES LESS THAN (202311010000),
--     SUBPARTITION p_2023_nov VALUES LESS THAN (202312010000),
--     SUBPARTITION p_2023_dec VALUES LESS THAN (202400000000)
--   ),
--   PARTITION p_2024 VALUES LESS THAN (202500000000)          -- Partition for 2024 data
--   (
--     SUBPARTITION p_2024_jan VALUES LESS THAN (202402010000),
--     SUBPARTITION p_2024_feb VALUES LESS THAN (202403010000),
--     SUBPARTITION p_2024_mar VALUES LESS THAN (202404010000),
--     SUBPARTITION p_2024_apr VALUES LESS THAN (202405010000),
--     SUBPARTITION p_2024_may VALUES LESS THAN (202406010000),
--     SUBPARTITION p_2024_jun VALUES LESS THAN (202407010000),
--     SUBPARTITION p_2024_jul VALUES LESS THAN (202408010000),
--     SUBPARTITION p_2024_aug VALUES LESS THAN (202409010000),
--     SUBPARTITION p_2024_sep VALUES LESS THAN (202410010000),
--     SUBPARTITION p_2024_oct VALUES LESS THAN (202411010000),
--     SUBPARTITION p_2024_nov VALUES LESS THAN (202412010000),
--     SUBPARTITION p_2024_dec VALUES LESS THAN (202500000000)
--   ),
--   PARTITION p_future VALUES LESS THAN (MAXVALUE)            -- Catch-all partition for future data
--   (
--     SUBPARTITION p_future_default VALUES LESS THAN (MAXVALUE) TABLESPACE FACT_TBSP
--   )
-- );


-- Create local B-tree index on start time ID for efficient partitioning queries
CREATE INDEX dw_schema.index_fact_trip_start_time
  ON dw_schema.fact_trip (fact_trip_start_time_id)
  LOCAL
  TABLESPACE INDEX_TBSP;

-- Create composite B-tree index on start and end station IDs for route-based queries
CREATE INDEX dw_schema.index_fact_trip_station_pair
  ON dw_schema.fact_trip (fact_trip_start_station_id, fact_trip_end_station_id)
  TABLESPACE INDEX_TBSP;

-- Create local bitmap index on user type ID for efficient filtering
CREATE BITMAP INDEX dw_schema.index_fact_trip_user_type
  ON dw_schema.fact_trip (fact_trip_user_type_id)
  LOCAL
  TABLESPACE INDEX_TBSP;
  
  
-- confirm
SELECT
    table_name
    , owner
    , tablespace_name
FROM DBA_TABLES
WHERE owner = 'dw_schema';

SELECT 
    index_name
    , index_type
    , table_name
    , uniqueness
    , constraint_index
    , owner
FROM dba_indexes
WHERE owner = 'dw_schema';