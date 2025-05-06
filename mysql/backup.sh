#!/bin/bash

# 设置备份目录和MySQL连接信息
# 需要设置以下环境变量：
# BACKUP_MYSQL_DB - 数据库名
# BACKUP_MYSQL_USERNAME - MySQL用户名
# BACKUP_MYSQL_PASSWORD - MySQL密码
# BACKUP_MYSQL_HOST - MySQL主机地址
# BACKUP_MYSQL_PORT - MySQL端口
# REMAIN_MINS - 在当前日期目录下保留备份文件的时间（分钟），可选
# REMAIN_DAYS - 保留备份目录的天数，超过此天数的目录将被删除，必填

# 设置备份的基准目录
base_backup_dir="/app_backup/$BACKUP_MYSQL_DB"
# 设置当天的备份目录，以数据库名和当前日期命名
backup_dir="$base_backup_dir/$(date +%F)"

# 检查必要的环境变量是否设置
if [ -z "$BACKUP_MYSQL_DB" ] || \
   [ -z "$BACKUP_MYSQL_USERNAME" ] || \
   [ -z "$BACKUP_MYSQL_PASSWORD" ] || \
   [ -z "$BACKUP_MYSQL_HOST" ] || \
   [ -z "$BACKUP_MYSQL_PORT" ] || \
   [ -z "$REMAIN_DAYS" ]; then
    echo "Error: Required environment variables (BACKUP_MYSQL_DB, BACKUP_MYSQL_USERNAME, BACKUP_MYSQL_PASSWORD, BACKUP_MYSQL_HOST, BACKUP_MYSQL_PORT, REMAIN_DAYS) are not set."
    exit 1
fi

# 创建当天的备份目录（如果不存在）
echo "Creating backup directory: $backup_dir"
mkdir -p "$backup_dir" || { echo "Error: Could not create directory $backup_dir"; exit 1; }

# 创建备份文件名，格式为：时-分-秒.sql.gz
backup_file="$backup_dir/$(date +%H-%M-%S).sql.gz"

echo "Starting MySQL dump to: $backup_file"
# 备份 MySQL 数据库
# 使用双引号确保变量值中的特殊字符不会导致问题
# 使用 pipefail 确保 mysqldump 出错时能捕获到
set -o pipefail
mysqldump -u "$BACKUP_MYSQL_USERNAME"\
    -p"$BACKUP_MYSQL_PASSWORD" \
    -h "$BACKUP_MYSQL_HOST"\
    -P "$BACKUP_MYSQL_PORT"\
    "$BACKUP_MYSQL_DB" \
    | gzip > "$backup_file"

# 检查mysqldump是否成功
if [ $? -eq 0 ]; then
    echo "MySQL dump successful."
else
    echo "Error: MySQL dump failed."
    # 可以选择删除不完整的备份文件
    # rm -f "$backup_file"
    exit 1 # 备份失败时退出
fi

# 删除当前目录 ($backup_dir) 下过早的备份文件 (基于分钟)
# 保留了您原有的文件清理逻辑，它作用于当天的目录
if [ -n "$REMAIN_MINS" ]; then # 检查 REMAIN_MINS 是否设置
    echo "Deleting files older than $REMAIN_MINS minutes in $backup_dir..."
    find "$backup_dir" -name "*.sql.gz" -mmin +$REMAIN_MINS -delete
    echo "File cleanup within current directory complete."
else
    echo "REMAIN_MINS not set. Skipping file cleanup within current directory."
fi

# 删除过早的备份目录 (基于天)
# 在基准备份目录 ($base_backup_dir) 下查找
# -maxdepth 1: 只查找顶级子目录，不进入子目录内部
# -type d: 只查找目录
# -name "????-??-??": 匹配 YYYY-MM-DD 格式的目录名，避免误删其他非日期目录
# -mtime +$REMAIN_DAYS: 查找修改时间在 REMAIN_DAYS 天前的目录
# -delete: 删除找到的目录及其内容
# 添加 -exec echo "Deleting {}" \; 在删除前打印要删除的目录，方便调试和查看
echo "Deleting directories older than $REMAIN_DAYS days in $base_backup_dir..."
find "$base_backup_dir" -maxdepth 1 -type d -name "????-??-??" -mtime +$REMAIN_DAYS -exec echo "Deleting {}" \; -delete
echo "Directory cleanup complete."

echo "Backup and cleanup script finished."