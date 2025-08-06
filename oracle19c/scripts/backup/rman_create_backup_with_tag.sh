#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name:     rman_create_backup_with_tag.sh
# Description:     Performs a full RMAN backup of the Oracle database and
#                  archivelogs with a given TAG.
# Usage:           ./rman_create_backup_with_tag.sh TAG_NAME
# Requirements:    Oracle RMAN must be available and the BACKUP_PATH must exist.
# -----------------------------------------------------------------------------

TAG_NAME=${1:-$(date +%Y-%m-%d)}

# Set the backup path
BACKUP_PATH="/opt/oracle/fast_recovery_area"

# Check if the backup directory exists
if [ ! -d "$BACKUP_PATH" ]; then
  echo "########################################################"
  echo "ERROR: Backup directory does not exist at $BACKUP_PATH"
  echo "########################################################" >&2

else

  echo "########################################################"
  echo "Starting full RMAN backup...   "
  echo "########################################################"

  # Run RMAN full backup
  rman target / <<EOF

RUN {

  # Clean up metadata and expired files
  CROSSCHECK BACKUP;
  DELETE NOPROMPT EXPIRED BACKUP;

  CROSSCHECK ARCHIVELOG ALL;
  DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;

  # Allocate channels for parallel backup
  ALLOCATE CHANNEL ch1 DEVICE TYPE DISK;
  ALLOCATE CHANNEL ch2 DEVICE TYPE DISK;

  # Perform full database backup with control file
  BACKUP AS BACKUPSET DATABASE
    FORMAT '$BACKUP_PATH/data_%T_D-%d_id-%I_FNO-%f_%u.bkp'
    INCLUDE CURRENT CONTROLFILE
    TAG 'FULL_BACKUP_$TAG_NAME';

  # Backup archivelogs and delete them after backup
  BACKUP ARCHIVELOG ALL
    FORMAT '$BACKUP_PATH/arch_%T_D_%d_id-%I_S-%e_T-%h_A-%a_%u.bkp'
    DELETE INPUT
    TAG 'ARCHIVELOG_BACKUP_$TAG_NAME';

  # Release channels
  RELEASE CHANNEL ch1;
  RELEASE CHANNEL ch2;
}

# Show backup summary
LIST BACKUP SUMMARY;

EOF

  echo "########################################################"
  echo "Full RMAN backup completed successfully. "
  echo "########################################################"

fi
