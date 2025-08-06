ALTER session set container = toronto_shared_bike;
show user;
show con_name;

-- user type per year + all year(marked as 2999)
SELECT 
    tm.dim_time_year                AS  dim_year
    , ut.dim_user_type_name         AS  dim_user_type
    , COUNT(*)                      AS  trip_year_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_year
    , ut.dim_user_type_name
UNION ALL
SELECT
    2999                            AS  dim_year
    , ut.dim_user_type_name         AS  dim_user_type
    , COUNT(*)                      AS  trip_year_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    ut.dim_user_type_name
ORDER BY
    dim_year
    , dim_user_type;

--Trip monthly trend per year + all year(marked as 2999)
SELECT 
    tm.dim_time_year                AS  dim_year
    , tm.dim_time_month             AS  dim_month
    , ut.dim_user_type_name         AS  dim_user_type
    , COUNT(*)                      AS  trip_month_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_month
    , ut.dim_user_type_name
UNION ALL
SELECT 
    2999                            AS  dim_year
    , tm.dim_time_month             AS  dim_month
    , ut.dim_user_type_name         AS  dim_user_type
    , COUNT(*)                      AS  trip_month_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_month
    , ut.dim_user_type_name
ORDER BY
    dim_year
    , dim_month
    , dim_user_type;

--Trip trend hourly per year + all yaear (mark as 2999)
SELECT 
    tm.dim_time_year                        AS  dim_year
    , tm.dim_time_hour                      AS  dim_hour
    , ut.dim_user_type_name                 AS  dim_user_type
    , COUNT(*)                              AS  trip_hour_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_hour
    , ut.dim_user_type_name
UNION ALL
SELECT 
    2999                                    AS  dim_year
    , tm.dim_time_hour                      AS  dim_hour
    , ut.dim_user_type_name                 AS  dim_user_type
    , COUNT(*)                              AS  trip_hour_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_hour
    , ut.dim_user_type_name
ORDER BY
    dim_year
    , dim_hour
    , dim_user_type;

-- Duration Trend monthly per year and all year(marked as 2999)
SELECT 
    tm.dim_time_year                            AS  dim_year
    , tm.dim_time_month                         AS  dim_month
    , ut.dim_user_type_name                     AS  dim_user_type
    , ROUND(AVG(ft.fact_trip_duration),2)       AS  duration_month_avg
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_month
    , ut.dim_user_type_name
UNION ALL
SELECT 
    2999                                        AS  dim_year
    , tm.dim_time_month                         AS  dim_month
    , ut.dim_user_type_name                     AS  dim_user_type
    , ROUND(AVG(ft.fact_trip_duration),2)       AS  duration_month_avg
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_month
    , ut.dim_user_type_name
ORDER BY
    dim_year
    , dim_month
    , dim_user_type;

--Duration trend hourly per year and all years (marked as 2999)
SELECT 
    tm.dim_time_year                            AS  dim_year
    , tm.dim_time_hour                          AS  dim_hour
    , ut.dim_user_type_name                     AS  dim_user_type
    , ROUND(AVG(ft.fact_trip_duration),2)       AS  duration_hour_avg
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_year
    , tm.dim_time_hour
    , ut.dim_user_type_name
UNION ALL
SELECT 
    2999                                        AS  dim_year
    , tm.dim_time_hour                          AS  dim_hour
    , ut.dim_user_type_name                     AS  dim_user_type
    , ROUND(AVG(ft.fact_trip_duration),2)       AS  duration_hour_avg
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
JOIN dw_schema.dim_user_type ut
ON ft.fact_trip_user_type_id = ut.dim_user_type_id
GROUP BY
    tm.dim_time_hour
    , ut.dim_user_type_name
ORDER BY
    dim_year
    , dim_hour
    , dim_user_type;

-- Top 10 station trend per year and all years(marked as 2999)
SELECT
    dim_year
    , dim_user_type
    , dim_start_station
    , trip_start_station_count
FROM (
    -- Top 10 popular start stations per user type per YEAR
    SELECT
        dt.dim_time_year                AS dim_year
        , ut.dim_user_type_name         AS dim_user_type
        , st.dim_station_name           AS dim_start_station
        , COUNT(*)                      AS trip_start_station_count
        , RANK() OVER (PARTITION BY dt.dim_time_year, ut.dim_user_type_name
            ORDER BY COUNT(*) DESC
        )                               AS station_rank
    FROM dw_schema.fact_trip ft
    JOIN dw_schema.dim_station st
        ON ft.fact_trip_start_station_id = st.dim_station_id
    JOIN dw_schema.dim_time dt
        ON ft.fact_trip_start_time_id = dt.dim_time_id
    JOIN dw_schema.dim_user_type ut
        ON ft.fact_trip_user_type_id = ut.dim_user_type_id
    WHERE
        UPPER(TRIM(st.dim_station_name)) <> 'UNKNOWN'
    GROUP BY
        dt.dim_time_year
        , ut.dim_user_type_name
        , st.dim_station_name
)
WHERE station_rank <= 10
UNION ALL
SELECT
    dim_year
    , dim_user_type
    , dim_start_station
    , trip_start_station_count
FROM (
    -- Top 10 popular start stations for ALL YEARS per user type
    SELECT
        2999 AS dim_year -- Marker for 'All Years'
        , ut.dim_user_type_name             AS dim_user_type
        , st.dim_station_name               AS dim_start_station
        , COUNT(*)                          AS trip_start_station_count
        , RANK() OVER (PARTITION BY ut.dim_user_type_name -- Partition only by user type
            ORDER BY COUNT(*) DESC
        )                                   AS station_rank
    FROM dw_schema.fact_trip ft
    JOIN dw_schema.dim_station st
        ON ft.fact_trip_start_station_id = st.dim_station_id
    -- No JOIN to dim_time for 'All Years' aggregation in terms of ranking partition
    JOIN dw_schema.dim_user_type ut
        ON ft.fact_trip_user_type_id = ut.dim_user_type_id
    WHERE
        UPPER(TRIM(st.dim_station_name)) <> 'UNKNOWN'
    GROUP BY
        ut.dim_user_type_name
        , st.dim_station_name
) 
WHERE station_rank <= 10
ORDER BY
    dim_year
    , dim_user_type
    , trip_start_station_count DESC;

 
-- Top 10 route trend
SELECT
    dim_year
    , dim_user_type
    , dim_start_station
    , dim_end_station
    , trip_route_count
FROM (
    -- Top 10 popular routes per user type per YEAR
    SELECT
        dt.dim_time_year AS dim_year
        , ut.dim_user_type_name AS dim_user_type -- Changed to name for better readability
        , st.dim_station_name AS dim_start_station
        , et.dim_station_name AS dim_end_station
        , COUNT(*) AS trip_route_count
        , RANK() OVER (
            PARTITION BY dt.dim_time_year, ut.dim_user_type_name -- Partition by year and user type name
            ORDER BY COUNT(*) DESC
        ) AS route_rank
    FROM dw_schema.fact_trip ft
    JOIN dw_schema.dim_station st
        ON ft.fact_trip_start_station_id = st.dim_station_id
    JOIN dw_schema.dim_station et
        ON ft.fact_trip_end_station_id = et.dim_station_id
    JOIN dw_schema.dim_time dt
        ON ft.fact_trip_start_time_id = dt.dim_time_id
    JOIN dw_schema.dim_user_type ut
        ON ft.fact_trip_user_type_id = ut.dim_user_type_id
    WHERE
        UPPER(TRIM(st.dim_station_name)) <> 'UNKNOWN'
        AND UPPER(TRIM(et.dim_station_name)) <> 'UNKNOWN'
        AND st.dim_station_name <> et.dim_station_name
    GROUP BY
        dt.dim_time_year
        , ut.dim_user_type_name
        , st.dim_station_name
        , et.dim_station_name
)
WHERE route_rank <= 10
UNION ALL
SELECT
    dim_year
    , dim_user_type
    , dim_start_station
    , dim_end_station
    , trip_route_count
FROM (
    -- Top 10 popular routes for ALL YEARS per user type
    SELECT
        2999 AS dim_year -- Marker for 'All Years'
        , ut.dim_user_type_name AS dim_user_type -- Changed to name for better readability
        , st.dim_station_name AS dim_start_station
        , et.dim_station_name AS dim_end_station
        , COUNT(*) AS trip_route_count
        , RANK() OVER (
            PARTITION BY ut.dim_user_type_name -- Partition only by user type name for 'All Years'
            ORDER BY COUNT(*) DESC
        ) AS route_rank
    FROM dw_schema.fact_trip ft
    JOIN dw_schema.dim_station st
        ON ft.fact_trip_start_station_id = st.dim_station_id
    JOIN dw_schema.dim_station et
        ON ft.fact_trip_end_station_id = et.dim_station_id
    -- No JOIN to dim_time needed for partitioning/grouping in this section
    JOIN dw_schema.dim_user_type ut
        ON ft.fact_trip_user_type_id = ut.dim_user_type_id
    WHERE
        UPPER(TRIM(st.dim_station_name)) <> 'UNKNOWN'
        AND UPPER(TRIM(et.dim_station_name)) <> 'UNKNOWN'
        AND st.dim_station_name <> et.dim_station_name
    GROUP BY
        ut.dim_user_type_name
        , st.dim_station_name
        , et.dim_station_name
)
WHERE route_rank <= 10
ORDER BY
    dim_year
    , dim_user_type
    , trip_route_count DESC; 

-- total station per year
SELECT 
    t.dim_time_year                                 AS dim_year
    , COUNT(DISTINCT fact_trip_start_station_id)    AS station_year_count
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t
ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY
    t.dim_time_year
UNION ALL
SELECT
    2999                                            AS dim_year
    , COUNT(DISTINCT dim_station_id)                AS station_year_count
FROM dw_schema.dim_station
ORDER BY
    dim_year;
    
-- bike count per year
SELECT 
    t.dim_time_year                         AS dim_year
    , COUNT(DISTINCT f.fact_trip_bike_id)   AS bike_year_count
FROM dw_schema.fact_trip f
JOIN dw_schema.dim_time t
ON f.fact_trip_start_time_id = t.dim_time_id
GROUP BY
    t.dim_time_year
UNION ALL
SELECT
    2999                                    AS dim_year
    , COUNT(dim_bike_id)                   AS bike_year_count
FROM dw_schema.dim_bike
ORDER BY
    dim_year;

-- trip count per year
SELECT 
    tm.dim_time_year                AS  dim_year
    , COUNT(*)                      AS  trip_year_count
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
GROUP BY
    tm.dim_time_year
UNION ALL
SELECT
    2999                            AS dim_year
    , COUNT(*)                      AS  trip_year_count
FROM dw_schema.fact_trip ft
ORDER BY
    dim_year;

-- avg duration per year
SELECT 
    tm.dim_time_year                            AS  dim_year
    , ROUND(AVG(ft.fact_trip_duration),2)       AS  duration_year_avg
FROM dw_schema.fact_trip ft
JOIN dw_schema.dim_time tm
ON ft.fact_trip_start_time_id = tm.dim_time_id
GROUP BY
    tm.dim_time_year
UNION ALL
SELECT
    2999                                        AS dim_year
    , ROUND(AVG(ft.fact_trip_duration),2)       AS  duration_year_avg
FROM dw_schema.fact_trip ft
ORDER BY
    dim_year;
