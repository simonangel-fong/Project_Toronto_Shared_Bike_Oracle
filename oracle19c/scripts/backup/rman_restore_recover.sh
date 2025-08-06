#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name:     rman_restore_recover.sh
# Description:     Restores and recovers the entire Oracle database using RMAN.
#                  It forces a startup to mount mode, restores datafiles,
#                  applies archive logs, and opens the database.
# Usage:           ./rman_restore_recover.sh
# Requirements:    Oracle RMAN must be available and backups must exist.
# -----------------------------------------------------------------------------

# Check if backup directory exists
BACKUP_PATH="/opt/oracle/fast_recovery_area"

if [ ! -d "$BACKUP_PATH" ]; then
  echo "########################################################"
  echo "ERROR: Backup directory does not exist at $BACKUP_PATH "
  echo "########################################################" >&2

else

  echo "########################################################"
  echo "Starting database restore and recovery...            "
  echo "########################################################"

  # Run RMAN restore and recovery
  rman target / <<EOF

# Mount the database forcefully
STARTUP FORCE MOUNT;

RUN {
  # Allocate channels for restore
  ALLOCATE CHANNEL ch1 DEVICE TYPE DISK;
  ALLOCATE CHANNEL ch2 DEVICE TYPE DISK;

  # Restore the full database
  RESTORE DATABASE;

  # Recover the database using archive logs and backups
  RECOVER DATABASE;

  # Release allocated channels
  RELEASE CHANNEL ch1;
  RELEASE CHANNEL ch2;
}

# Open the database after successful recovery
ALTER DATABASE OPEN;

EOF

  echo "########################################################"
  echo "Database restore and recovery completed successfully"
  echo "########################################################"

fi
