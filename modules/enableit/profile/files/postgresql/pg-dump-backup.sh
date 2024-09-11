#!/bin/bash

set -o nounset
set -o errexit
set -e

PATH=/usr/bin:/usr/sbin:/bin:/sbin
DATE=$(date +%y%m%d-%H%M)
HOSTNAME=$(hostname -s)

. /etc/obmondo/pgsql/backup.env

which xz >/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
  echo "Failed to find xz compression utility - failing backup!"
  exit 1
fi

pg_dumpall -Upostgres -g | xz >$BACKUP_DIR/$HOSTNAME-$DATE-globals.sqlc.xz
psql -AtU postgres -c "SELECT datname FROM pg_database \
                          WHERE NOT datistemplate"| \
while read f; 
   do pg_dump -Upostgres --format=c $f | xz >$BACKUP_DIR/$HOSTNAME-$DATE-$f.sqlc.xz;
done;

find $BACKUP_DIR -type f -prune -mtime +$KEEP_DAYS -exec rm -f {} \;

