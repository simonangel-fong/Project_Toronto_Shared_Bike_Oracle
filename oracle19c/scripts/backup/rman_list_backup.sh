#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name:     rman_list_backup.sh
# Description:     List all backup.
# Usage:           ./rman_list_backup.sh
# Requirements:    Oracle RMAN must be available and the BACKUP_PATH must exist.
# -----------------------------------------------------------------------------

# Set the backup path
BACKUP_PATH="/opt/oracle/fast_recovery_area"

# Check if the backup directory exists
if [ ! -d "$BACKUP_PATH" ]; then
  echo "########################################################"
  echo "ERROR: Backup directory does not exist at $BACKUP_PATH"
  echo "########################################################" >&2

else

  echo "########################################################"
  echo "List full RMAN backup...   "
  echo "########################################################"

  # Run RMAN full backup
  rman target / <<EOF

# Show backup summary
LIST BACKUP SUMMARY;

EOF

fi
