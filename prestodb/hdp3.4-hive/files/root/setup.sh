#!/bin/bash -ex

mkdir -p /opt/hadoop/logs
chmod -R 777 /opt/hadoop

# 2 start hdfs
mkdir -p /var/log/hadoop-hdfs
chown hdfs:hdfs /var/log/hadoop-hdfs

su -c "echo 'N' | hdfs namenode -format" hdfs

su -c "hdfs namenode  2>&1 > /var/log/hadoop-hdfs/hadoop-hdfs-namenode.log" hdfs&
sleep 15

# 3 ensure hive loads mysql java connector to classpath
cp /usr/share/java/mysql-connector-java.jar $HIVE_HOME/lib/

# 4 copy hive-site.xml configuration to actual hive conf directory
cp /etc/hive/conf/hive-site.xml /opt/hive/conf

# 5 init log directories
mkdir -p /var/log/hive
chown hdfs:hdfs /var/log/hive

mkdir -p /var/log/hadoop-yarn
chown hdfs:hdfs /var/log/hadoop-yarn

# 6 setup metastore
mysqld --initialize

chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

/usr/sbin/mysqld --user=mysql --skip-networking=0 &
sleep 10s

MYSQL_PASS=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

cd /opt/hive/scripts/metastore/upgrade/mysql/
/usr/bin/mysqladmin --user=root --password="$MYSQL_PASS" password 'root'
echo "CREATE DATABASE metastore; USE metastore; SOURCE hive-schema-4.0.0.mysql.sql;" | mysql -u root -proot

pkill mysqld
sleep 10s
mkdir /var/log/mysql/
chown mysql:mysql /var/log/mysql/
