#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name:     mv_refresh.sh
# Description:     Refreshes materialized views and confirms the operation
#                  by executing SQL scripts.
# Usage:           ./mv_refresh.sh
# Requirements:    Must be run by a user with SYSDBA privileges.
# -----------------------------------------------------------------------------

echo "#######################################################"
echo "Refresh and confirm materialized views"
echo "#######################################################"

sqlplus -s / as sysdba <<EOF
-- Refresh materialized views
@/opt/oracle/scripts/mv/mv_refresh.sql
-- Confirm materialized view refresh status
-- @/opt/oracle/scripts/mv/mv_confirm.sql

exit
EOF
