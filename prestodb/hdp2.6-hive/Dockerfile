# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM prestodb/centos-openjdk:10
MAINTAINER Presto community <https://prestodb.io/community.html>

# Change default timezone
RUN ln -snf "/usr/share/zoneinfo/Asia/Kathmandu" /etc/localtime && echo "Asia/Kathmandu" > /etc/timezone

RUN dnf install -y wget

# Install Hadoop
RUN wget -nv https://dlcdn.apache.org/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz -P /tmp/ \
    && tar -xzf /tmp/hadoop-3.4.0.tar.gz -C /opt/ \
    && mv /opt/hadoop-3.4.0 /opt/hadoop \
    && rm /tmp/hadoop-3.4.0.tar.gz

# Install Hive
RUN wget -nv https://dlcdn.apache.org/hive/hive-4.0.0/apache-hive-4.0.0-bin.tar.gz -P /tmp/ \
    && tar -xzf /tmp/apache-hive-4.0.0-bin.tar.gz -C /opt/ \
    && mv /opt/apache-hive-4.0.0-bin /opt/hive \
    && rm /tmp/apache-hive-4.0.0-bin.tar.gz

ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV HIVE_HOME=/opt/hive
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin

# Install MySQL
RUN wget -nv https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.4.0-1.el9.noarch.rpm -P /tmp/ \
    && rpm -i /tmp/mysql-connector-j-8.4.0-1.el9.noarch.rpm

# Cleanup
RUN dnf clean all && rm -rf /tmp/* /var/tmp/*

# Copy configuration files
COPY ./files /

# Run setup script
RUN /root/setup.sh \
  && rm -rf /tmp/* /var/tmp/*

# Setup sock proxy
RUN yum install -y openssh openssh-clients openssh-server && yum -y clean all
RUN ssh-keygen -t rsa -b 4096 -C "automation@prestodb.io" -N "" -f /root/.ssh/id_rsa \
  && ssh-keygen -t rsa -b 4096 -N "" -f /etc/ssh/ssh_host_rsa_key \
  && ssh-keygen -t dsa -b 1024 -N "" -f /etc/ssh/ssh_host_dsa_key \
  && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 755 /root && chmod 700 /root/.ssh
RUN passwd --unlock root

# HDFS ports
EXPOSE 1004 1006 8020 50010 50020 50070 50075 50470

# YARN ports
EXPOSE 8030 8031 8032 8033 8040 8041 8042 8088 10020 19888

# HIVE ports
EXPOSE 9083 10000

# SOCKS port
EXPOSE 1180

CMD supervisord -c /etc/supervisord.conf
