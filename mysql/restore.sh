#!/bin/bash

restore_file_dir=/app_restore

cd $restore_file_dir || exit

# Find the unique file in the directory
file=$(find . -type f -iname '*.sql' -o -iname '*.sql.gz' | head -1)

# Check if the file exists
if [ -n "$file" ]; then
    if [[ "$file" == *.sql.gz ]]; then
        echo "File $file has a .sql.gz extension"
        gunzip -c $restore_file_dir/$file > /temp/bkfile
    elif [[ "$file" == *.sql ]]; then
        echo "File $file has a .sql extension"
        cp $restore_file_dir/$file /temp/bkfile
    fi
else
    echo "No file found in /bkfile/ directory"
fi

mysql -h $RESTORE_MYSQL_HOST \
  -u $RESTORE_MYSQL_USERNAME \
  -P $RESTORE_MYSQL_PORT \
  -p$RESTORE_MYSQL_PASSWORD \
  $RESTORE_MYSQL_DB < /temp/bkfile
