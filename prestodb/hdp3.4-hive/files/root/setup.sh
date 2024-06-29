#!/bin/bash -ex

mkdir -p /opt/hadoop/logs
chown hdfs:hdfs /opt/hadoop/logs

# 2 start hdfs
su -c "hdfs namenode -format" hdfs

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

# 6 stop hdfs

# 7 setup metastore
mysqld --initialize

/usr/sbin/mysqld --user=mysql --socket=/var/lib/mysql/mysql.sock --skip-networking=0 --skip-grant-tables &
sleep 10s

cd /opt/hive/scripts/metastore/upgrade/mysql/
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" | mysql
echo "CREATE DATABASE metastore; USE metastore; SOURCE hive-schema-1.2.1000.mysql.sql;" | mysql
/usr/bin/mysqladmin -u root password 'root'

pkill mysqld
sleep 10s
mkdir /var/log/mysql/
chown mysql:mysql /var/log/mysql/
