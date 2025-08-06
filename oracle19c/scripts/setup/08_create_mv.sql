-- ============================================================================
-- Script Name : create_mv.sql
-- Purpose     : Create materialized view logs and materialized views for efficient
--               querying and reporting in the Toronto Shared Bike Data Warehouse
-- Author      : Wenhao Fang
-- Date        : 2025-05-07
-- User        : Execute as a user with appropriate privileges in the toronto_shared_bike PDB
-- Notes       : Ensure the dw_schema, fact, and dimension tables are created and populated
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

-- ============================================================================
-- Creating MV LOG
-- ============================================================================

-- Create materialized view log on fact_trip for fast refresh support
--DROP MATERIALIZED VIEW LOG ON dw_schema.fact_trip;
CREATE MATERIALIZED VIEW LOG ON dw_schema.fact_trip
TABLESPACE MV_TBSP
WITH ROWID, SEQUENCE (
    fact_trip_start_time_id
    , fact_trip_start_station_id
    , fact_trip_end_station_id
    )
INCLUDING NEW VALUES;

-- Create materialized view log on dim_time for fast refresh support
--DROP MATERIALIZED VIEW LOG ON dw_schema.dim_time;
CREATE MATERIALIZED VIEW LOG ON dw_schema.dim_time
TABLESPACE MV_TBSP
WITH ROWID, SEQUENCE (
    dim_time_id
    , dim_time_year
    , dim_time_month
    , dim_time_hour
    )
INCLUDING NEW VALUES;

-- Create materialized view log on dim_station for fast refresh support
--DROP MATERIALIZED VIEW LOG ON dw_schema.dim_station;
CREATE MATERIALIZED VIEW LOG ON dw_schema.dim_station
TABLESPACE MV_TBSP
WITH ROWID, SEQUENCE (
    dim_station_id
    , dim_station_name
    )
INCLUDING NEW VALUES;

-- ============================================================================
-- Creating MV for time-based and user-based analysis
-- ============================================================================
--DROP MATERIALIZED VIEW dw_schema.mv_user_time;
CREATE MATERIALIZED VIEW dw_schema.mv_user_time
TABLESPACE MV_TBSP
PARTITION BY RANGE (dim_year) (
    PARTITION p_before  VALUES LESS THAN (2019)  -- Partition for pre-2019 data
    , PARTITION p_2020  VALUES LESS THAN (2020)  -- Partition for 2020 data
    , PARTITION p_2021  VALUES LESS THAN (2021)  -- Partition for 2021 data
    , PARTITION p_2022  VALUES LESS THAN (2022)  -- Partition for 2022 data
    , PARTITION p_2023  VALUES LESS THAN (2023)  -- Partition for 2023 data
    , PARTITION p_2024  VALUES LESS THAN (2024)  -- Partition for 2024 data
    , PARTITION p_2025  VALUES LESS THAN (2025)  -- Partition for 2025 data
    , PARTITION p_max   VALUES LESS THAN (MAXVALUE)  -- Catch-all partition
)
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND  -- Enable incremental updates
ENABLE QUERY REWRITE
AS
SELECT	
    dim_time_year								AS dim_year
	, dim_time_month							AS dim_month
	, dim_time_hour								AS dim_hour
	, dim_user_type_name						AS dim_user
    , COUNT(*)									AS trip_count
	, SUM(fact_trip_duration)	                AS duration_sum
	, ROUND(AVG(fact_trip_duration),2)	        AS duration_avg
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t 
    ON f.fact_trip_start_time_id = t.dim_time_id
JOIN dw_schema.dim_user_type u
	ON f.fact_trip_user_type_id = u.dim_user_type_id
GROUP BY
	dim_time_year
	, dim_time_month
	, dim_time_hour
	, dim_user_type_name
;

-- Create composite B-tree index for year-month queries on mv_trip_time
CREATE INDEX dw_schema.idx_mv_time
ON dw_schema.mv_user_time (dim_year, dim_month, dim_hour)
TABLESPACE MV_TBSP;

-- ============================================================================
-- Creating MV for station-based and user-based analysis
-- ============================================================================
--DROP MATERIALIZED VIEW dw_schema.mv_user_station;
CREATE MATERIALIZED VIEW dw_schema.mv_user_station
TABLESPACE MV_TBSP
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
AS

WITH ranked_station_year_all AS (
  SELECT
    trip_count,
    dim_station,
    dim_year,
    RANK() OVER(PARTITION BY dim_year ORDER BY trip_count DESC) AS trip_rank
  FROM (
    SELECT 
      COUNT(*) AS trip_count,
      dim_station_name AS dim_station,
      dim_time_year AS dim_year
    FROM dw_schema.fact_trip f
    JOIN dw_schema.dim_time t 
      ON f.fact_trip_start_time_id = t.dim_time_id
    JOIN dw_schema.dim_station s 
      ON f.fact_trip_start_station_id = s.dim_station_id
    JOIN dw_schema.dim_user_type u 
      ON f.fact_trip_user_type_id = u.dim_user_type_id
    WHERE dim_station_name <> 'UNKNOWN'
    GROUP BY dim_station_name, dim_time_year
  ) station_all_year
),
ranked_station_year_user AS (
  SELECT 
    trip_count,
    dim_year,
    dim_user,
    dim_station,
    RANK() OVER(PARTITION BY dim_year, dim_user ORDER BY trip_count DESC) AS trip_rank
  FROM (
    SELECT
      COUNT(*) AS trip_count,
      dim_time_year AS dim_year,
      dim_user_type_name AS dim_user,
      dim_station_name AS dim_station
    FROM dw_schema.fact_trip f
    JOIN dw_schema.dim_time t
      ON f.fact_trip_start_time_id = t.dim_time_id
    JOIN dw_schema.dim_station s
      ON f.fact_trip_start_station_id = s.dim_station_id
    JOIN dw_schema.dim_user_type u
      ON f.fact_trip_user_type_id = u.dim_user_type_id
    WHERE dim_station_name <> 'UNKNOWN'
    GROUP BY dim_time_year, dim_user_type_name, dim_station_name
  ) station_user_year
)
SELECT
  trip_count,
  dim_station,
  dim_year,
  'all' AS dim_user
FROM ranked_station_year_all
WHERE trip_rank <= 10

UNION ALL

SELECT 
  trip_count,
  dim_station,
  dim_year,
  dim_user
FROM ranked_station_year_user
WHERE trip_rank <= 10
;

-- Create composite B-tree index for year queries on mv_user_station
CREATE INDEX dw_schema.idx_mv_user_station_year
ON dw_schema.mv_user_station (dim_year)
TABLESPACE MV_TBSP;

-- Create composite B-tree index for station queries on mv_user_station
CREATE INDEX dw_schema.idx_mv_user_station_station
ON dw_schema.mv_user_station (dim_station)
TABLESPACE MV_TBSP;

-- ============================================================================
-- Creating MV for station count
-- ============================================================================
--DROP MATERIALIZED VIEW dw_schema.mv_station_count;
CREATE MATERIALIZED VIEW dw_schema.mv_station_count
TABLESPACE MV_TBSP
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT
	COUNT(DISTINCT f.fact_trip_start_station_id)	AS	"station_count"
	, t.dim_time_year								AS	"dim_year"
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t
ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY t.dim_time_year
;

-- ============================================================================
-- Creating MV for bike count
-- ============================================================================
--DROP MATERIALIZED VIEW dw_schema.mv_bike_count;
CREATE MATERIALIZED VIEW dw_schema.mv_bike_count
TABLESPACE MV_TBSP
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT
	COUNT(DISTINCT f.fact_trip_bike_id)	AS	"bike_count"
	, t.dim_time_year					AS	"dim_year"
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t
ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY t.dim_time_year
;

-- Confirm
SELECT 
    owner
    , mview_name
    , refresh_mode
    , refresh_method
    , last_refresh_date
    , compile_state
FROM all_mviews
ORDER BY owner, mview_name;