#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name:     multiple_year_etl_job.sh
# Description:     Runs ELT jobs for a range of years by invoking
#                  single_year_etl_job.sh for each year in the range.
# Usage:           ./multiple_year_etl_job.sh [START_YEAR] [END_YEAR]
# Example:         ./multiple_year_etl_job.sh 2019 2021
# Requirements:    The script single_year_etl_job.sh must be executable and present at the specified path.
# -----------------------------------------------------------------------------

# Set the start and end year from input arguments, defaulting to 2019–2020
START_YEAR=${1:-2019}
END_YEAR=${2:-2020}

echo "#######################################################"
echo "Running ETL jobs from $START_YEAR to $END_YEAR... "
echo "#######################################################"

# Loop over the year range and call the single year ETL job for each
for ((year = START_YEAR; year <= END_YEAR; year++)); do
    echo "############################################"
    echo "Starting ETL job for year $year.         "
    echo "############################################"
    
    # Call the single year ETL job script with the current year
    bash /opt/oracle/scripts/etl/single_year_etl_job.sh "$year"

    echo "############################################"
    echo "Finished ETL job for year $year          "
    echo "############################################"
    echo
done
