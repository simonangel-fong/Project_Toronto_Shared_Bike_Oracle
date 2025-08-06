#!/bin/bash

ORCL_PDB="toronto_shared_bike"
ORCL_USER="dataEngineer"
ORCL_DPUMP_PATH="/project/dpump"
ORCL_DPUMP_DIR="dpump_dir"

ORCL_DPUMP_DIM_FILE="dw_export_dim.dmp"
ORCL_DPUMP_DIM_LOGFILE="dw_import_dim.log"
ORCL_DPUMP_DIM_TABLES="
    dw_schema.dim_time          \
    , dw_schema.dim_station     \
    , dw_schema.dim_bike        \
    , dw_schema.dim_user_type
"

ORCL_DPUMP_FACT_FILE="dw_export_fact.dmp"
ORCL_DPUMP_FACT_LOGFILE="dw_import_fact.log"
ORCL_DPUMP_FACT_TABLES="dw_schema.fact_trip"

set -e # Exit on any error

# Check if the backup path exists
if [ ! -d "$ORCL_DPUMP_PATH" ]; then
    echo "########################################################"
    echo "ERROR: Dump directory does not exist at $ORCL_DPUMP_PATH"
    echo "########################################################" >&2
else
    echo "#####################################################"
    echo "Importing Data..."
    echo "#####################################################"

    sqlplus -s / as sysdba <<EOF
    WHENEVER SQLERROR EXIT SQL.SQLCODE
    ALTER SESSION SET container = ${ORCL_PDB};
    CREATE OR REPLACE DIRECTORY ${ORCL_DPUMP_DIR} AS '${ORCL_DPUMP_PATH}';
    GRANT READ, WRITE ON DIRECTORY ${ORCL_DPUMP_DIR} TO ${ORCL_USER};
    EXIT;
EOF

    # Clean up old exports
    rm -f ${ORCL_DPUMP_PATH}/dw_import*.log

    # Run data pump import for dim
    impdp ${ORCL_USER}/'SecurePassword!23'@${ORCL_PDB} \
        tables=${ORCL_DPUMP_DIM_TABLES}         \
        directory=${ORCL_DPUMP_DIR}             \
        dumpfile=${ORCL_DPUMP_DIM_FILE}         \
        logfile=${ORCL_DPUMP_DIM_LOGFILE}       \
        content=data_only                       \
        TRANSFORM=DISABLE_ARCHIVE_LOGGING:y     \
        PARALLEL=8                              \
        DIRECT=YES                              \
        BUFFER=1000000


    # Run data pump import for fact
    impdp ${ORCL_USER}/'SecurePassword!23'@${ORCL_PDB} \
        tables=${ORCL_DPUMP_FACT_TABLES}        \
        directory=${ORCL_DPUMP_DIR}             \
        dumpfile=${ORCL_DPUMP_FACT_FILE}        \
        logfile=${ORCL_DPUMP_FACT_LOGFILE}      \
        content=data_only                       \
        TRANSFORM=DISABLE_ARCHIVE_LOGGING:y     \
        PARALLEL=8                              \
        DIRECT=YES                              \
        BUFFER=1000000
fi
