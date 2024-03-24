## Build

```bash
docker build -t mysql-helper .
```

## Restore

map dir to `/app_restore`, the dir should have only one file,

while is the file to be restore.

the file should be *.sql or *.sql.gz (gunzip automatically)

e.g.

```bash
docker run --rm --env-file env -v $PWD/gzs:/app_restore mysql-helper
```

env:

```
RESTORE_MYSQL_HOST=
RESTORE_MYSQL_PORT=
RESTORE_MYSQL_USERNAME=
RESTORE_MYSQL_PASSWORD=
RESTORE_MYSQL_DB=
```

## Backup

```bash
docker run --rm --env-file env -v $PWD/backupdir:/app_backup mysql-helper /app/backup.sh
```

env:

```
BACKUP_MYSQL_HOST=
BACKUP_MYSQL_PORT=
BACKUP_MYSQL_USERNAME=
BACKUP_MYSQL_PASSWORD=
BACKUP_MYSQL_DB=
```
