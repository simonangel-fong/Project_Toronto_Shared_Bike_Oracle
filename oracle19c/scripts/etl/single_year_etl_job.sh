#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name:     single_year_etl_job.sh
# Description:     Executes an ELT pipeline (Extract, Load, Transform, Confirm)
#                  for a specified year. Defaults to 2019 if no year is provided.
# Usage:           ./single_year_etl_job.sh [YEAR]
# Requirements:    Must be run by a user with SYSDBA privileges.
# -----------------------------------------------------------------------------

# Set the target YEAR from the first argument or default to 2019
YEAR=${1:-2019}

# -----------------------------------------------------------------------------
# Step 1: Update directory object in the database for the target year
# -----------------------------------------------------------------------------
echo
echo "###########################################"
echo "Update directory for year $YEAR.        "
echo "###########################################"

sqlplus -s / as sysdba <<EOF
ALTER SESSION SET container=toronto_shared_bike;

BEGIN
    update_directory_for_year(${YEAR});
END;
/
exit
EOF

# -----------------------------------------------------------------------------
# Step 2: Extract data from external sources or staging areas
# -----------------------------------------------------------------------------
echo
echo "###########################################"
echo "Extract data for year $YEAR.            "
echo "###########################################"

sqlplus -s / as sysdba <<EOF
@/opt/oracle/scripts/etl/etl_extract.sql
exit
EOF

# -----------------------------------------------------------------------------
# Step 3: Transform the extracted data into dimensional model format
# -----------------------------------------------------------------------------
echo
echo "###########################################"
echo "Transform data for year $YEAR.          "
echo "###########################################"

sqlplus -s / as sysdba <<EOF
@/opt/oracle/scripts/etl/etl_transform.sql
exit
EOF

# -----------------------------------------------------------------------------
# Step 4: Load the transformed data into the data warehouse fact and dimension tables
# -----------------------------------------------------------------------------
echo
echo "###########################################"
echo "Load data for year $YEAR.               "
echo "###########################################"

sqlplus -s / as sysdba <<EOF
@/opt/oracle/scripts/etl/etl_load.sql
exit
EOF

# -----------------------------------------------------------------------------
# Step 5: Confirm that the data load was successful and log results
# -----------------------------------------------------------------------------
# echo
# echo "###########################################"
# echo "Confirm ETL for year $YEAR.             "
# echo "###########################################"

# sqlplus -s / as sysdba <<EOF
# @/project/scripts/etl/etl_confirm.sql
# exit
# EOF

# -----------------------------------------------------------------------------
# Completion message
# -----------------------------------------------------------------------------
echo
echo "###########################################"
echo "Finished ETL for year $YEAR.            "
echo "###########################################"
