#!/bin/bash

PDB_NAME="toronto_shared_bike"
SCHEMA_NAME="dw_schema"
MV_VIEW_LIST=("mv_user_time" "mv_user_station" "mv_station_count" "mv_bike_count")

echo "#######################################################"
echo "Export Job Starts..."
echo "#######################################################"

for VIEW in "${MV_VIEW_LIST[@]}"
do
  EXPORT_PATH="/export/${VIEW}.csv"

  echo "#######################################################"
  echo "Exporting $VIEW..."
  echo "#######################################################"
  
  sqlplus -s / as sysdba <<EOF
ALTER SESSION SET CONTAINER = $PDB_NAME;

SET FEEDBACK OFF
SET HEADING ON
SET LINESIZE 1000
SET PAGESIZE 50000
SET COLSEP ','
SET TRIMSPOOL ON
SET TERMOUT OFF
SET UNDERLINE OFF

SPOOL $EXPORT_PATH
SELECT * FROM $SCHEMA_NAME.$VIEW;
SPOOL OFF
EXIT;
EOF

done

echo "#######################################################"
echo "Export Job Finish."
echo "#######################################################"



