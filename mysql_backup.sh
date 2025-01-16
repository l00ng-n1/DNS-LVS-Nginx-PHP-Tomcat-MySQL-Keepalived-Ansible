#!/bin/bash

REMOTE_HOST="192.168.74.12"
REMOTE_DIR="/data/"

IP_ADDRESS=$(ip addr show eth1 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)

# 当前日期
DATE=$(date +\%Y_\%m_\%d)

# MySQL 用户和密码
MYSQL_USER="root"
MYSQL_PASSWORD="123456"

# 数据库名
DB1="jpress"
DB2="discuz"

# 备份文件保存路径
BACKUP_DIR="/tmp"

# 备份文件名
BACKUP_FILE1="${BACKUP_DIR}/${DATE}_jpress.sql.gz"
BACKUP_FILE2="${BACKUP_DIR}/${DATE}_discuz.sql.gz"

# 执行 mysqldump 备份
mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $DB1 -F -E -R --triggers --single-transaction --source-data=2 --flush-privileges --default-character-set=utf8 --hex-blob | gzip > $BACKUP_FILE1          
mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $DB2 -F -E -R --triggers --single-transaction --source-data=2 --flush-privileges --default-character-set=utf8 --hex-blob | gzip > $BACKUP_FILE2

# 检查目标目录是否存在，如果不存在，则创建它
ssh -o StrictHostKeyChecking=no root@$REMOTE_HOST "mkdir -p $REMOTE_DIR/$IP_ADDRESS"

# 远程传输备份文件到 devops 服务器
scp $BACKUP_FILE1 root@$REMOTE_HOST:$REMOTE_DIR/$IP_ADDRESS
scp $BACKUP_FILE2 root@$REMOTE_HOST:$REMOTE_DIR/$IP_ADDRESS

# 删除本地备份文件
rm -f $BACKUP_FILE1 $BACKUP_FILE2