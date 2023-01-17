#!/bin/bash

# name of postgres user same for 3 bases - 'dwhpostgres'
# -X stream –  используется для включения необходимых wal файлов в резервную копию, stream означает потоковую передачу WAL.

# Set the backup directory
BACKUP_DIR=/usr/local/pgsql/backup/

# Stop the Postgres service
systemctl stop postgresql

# Create the backup of the mrr database
pg_basebackup -U dwhpostgres -D $BACKUP_DIR/mrr-$(date +%Y-%m-%d-%H-%M-%S).tar -F tar -X stream -d mrr

# Create the backup of the stg database
pg_basebackup -U dwhpostgres -D $BACKUP_DIR/stg-$(date +%Y-%m-%d-%H-%M-%S).tar -F tar -X stream -d stg

# Create the backup of the dwh database
pg_basebackup -U dwhpostgres -D $BACKUP_DIR/dwh-$(date +%Y-%m-%d-%H-%M-%S).tar -F tar -X stream -d dwh

# Start the Postgres service
systemctl start postgresql