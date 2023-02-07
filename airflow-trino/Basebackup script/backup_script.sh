#!/bin/bash

# name of postgres user same for 3 bases - 'dwhpostgres'
# -X stream –  используется для включения необходимых wal файлов в резервную копию, stream означает потоковую передачу WAL.

# Set the backup directory
BACKUP_DIR=/usr/local/pgsql/backup/

# Stop the Postgres service
systemctl stop postgresql

# Create the backup of the PstgreSQL cluster database
pg_basebackup -U dwhpostgres -D $BACKUP_DIR/mrr-$(date +%Y-%m-%d-%H-%M-%S).tar -F tar -X stream

# Start the Postgres service
systemctl start postgresql