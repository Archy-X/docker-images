#!/bin/bash -ex

mkdir -p /opt/hadoop/logs
chmod -R 777 /opt/hadoop

# 2 start hdfs
mkdir -p /var/log/hadoop-hdfs
chown hdfs:hdfs /var/log/hadoop-hdfs

su -c "echo 'N' | hdfs namenode -format" hdfs

su -c "hdfs namenode  2>&1 > /var/log/hadoop-hdfs/hadoop-hdfs-namenode.log" hdfs&
sleep 15

# 4 init basic hdfs directories

# 4.1 Create an hdfs home directory for the yarn user. For some reason, init-hdfs doesn't do so.
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -mkdir /user/yarn && /usr/bin/hadoop fs -chown yarn:yarn /user/yarn'
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -chmod -R 1777 /tmp/hadoop-yarn'
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -mkdir /tmp/hadoop-yarn/staging && /usr/bin/hadoop fs -chown mapred:mapred /tmp/hadoop-yarn/staging && /usr/bin/hadoop fs -chmod -R 1777 /tmp/hadoop-yarn/staging'
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -mkdir /tmp/hadoop-yarn/staging/history && /usr/bin/hadoop fs -chown mapred:mapred /tmp/hadoop-yarn/staging/history && /usr/bin/hadoop fs -chmod -R 1777 /tmp/hadoop-yarn/staging/history'

# 5 init hive directories
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -mkdir /user/hive/warehouse'
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -chmod 1777 /user/hive/warehouse'
# su -s /bin/bash hdfs -c '/opt/hadoop/bin/hadoop fs -chown hive /user/hive/warehouse'

cp /usr/share/java/mysql-connector-java.jar $HIVE_HOME/lib/

cp /etc/hive/conf/hive-site.xml /opt/hive/conf

mkdir -p /var/log/hive
chown hdfs:hdfs /var/log/hive

mkdir -p /var/log/hadoop-yarn
chown hdfs:hdfs /var/log/hadoop-yarn
# 6 stop hdfs

# 7 setup metastore
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
