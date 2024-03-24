#!/bin/bash

# 设置备份目录和MySQL连接信息
backup_dir="/app_backup"

# 创建备份文件名，格式为：db_name-年-月-日_时-分-秒.sql.gz
backup_file="$backup_dir/$BACKUP_MYSQL_DB-$(date +%F_%H-%M-%S).sql.gz"

# 备份MySQL数据库
mysqldump -u "$BACKUP_MYSQL_USERNAME"\
    -p"$BACKUP_MYSQL_PASSWORD" \
    -h "$BACKUP_MYSQL_HOST"\
    -P "$BACKUP_MYSQL_PORT"\
    "$BACKUP_MYSQL_DB" \
    | gzip > "$backup_file"


# 删除过早的备份
find "$backup_dir" -name "*.sql.gz" -mmin +$REMAIN_MINS -delete
