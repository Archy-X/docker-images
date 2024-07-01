#!/bin/bash -ex

mkdir -p /opt/hadoop/logs
chown hdfs:hdfs /opt/hadoop/logs

# 2 start hdfs
mkdir -p /var/log/hadoop-hdfs
chown hdfs:hdfs /var/log/hadoop-hdfs
su -c "hdfs namenode -format 2>&1 > /var/log/hadoop-hdfs/hadoop-hdfs-namenode.log" hdfs&
sleep 15

# 4 init basic hdfs directories

# 4.1 Create an hdfs home directory for the yarn user. For some reason, init-hdfs doesn't do so.
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -mkdir /user/yarn && /usr/bin/hadoop fs -chown yarn:yarn /user/yarn'
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -chmod -R 1777 /tmp/hadoop-yarn'
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -mkdir /tmp/hadoop-yarn/staging && /usr/bin/hadoop fs -chown mapred:mapred /tmp/hadoop-yarn/staging && /usr/bin/hadoop fs -chmod -R 1777 /tmp/hadoop-yarn/staging'
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -mkdir /tmp/hadoop-yarn/staging/history && /usr/bin/hadoop fs -chown mapred:mapred /tmp/hadoop-yarn/staging/history && /usr/bin/hadoop fs -chmod -R 1777 /tmp/hadoop-yarn/staging/history'

# 5 init hive directories
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -mkdir -p /user/hive/warehouse'
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -chmod 1777 /user/hive/warehouse'
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -chown hive /user/hive/warehouse'
mkdir -p /var/log/hive
chown hdfs:hdfs /var/log/hive

# 6 stop hdfs

# 7 setup metastore
mysqld --initialize

chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

/usr/sbin/mysqld --user=mysql --socket=/var/lib/mysql/mysql.sock --skip-networking=0 --skip-grant-tables &
sleep 10s

cd /opt/hive/scripts/metastore/upgrade/mysql/
echo "CREATE DATABASE metastore; USE metastore; SOURCE hive-schema-1.2.0.mysql.sql;" | mysql

pkill mysqld
sleep 10s
mkdir /var/log/mysql/
chown mysql:mysql /var/log/mysql/
