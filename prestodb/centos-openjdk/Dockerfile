FROM quay.io/centos/centos:stream9
MAINTAINER Presto community <https://prestodb.io/community.html>

# Install OpenJDK 11 and dependencies
RUN set -xeu && \
    dnf install -y java-11-openjdk && \
    \
    # Install Python and tools
    dnf install -y epel-release && \
    dnf install -y python3-pip && \
    pip3 install --upgrade pip && \
    pip3 install --upgrade setuptools && \
    pip3 install supervisor && \
    \
    # Install additional tools
    dnf install -y vim && \
    \
    # Cleanup
    dnf clean all && rm -rf /var/cache/dnf /tmp/* /var/tmp/*

# Set JAVA_HOME environment variable
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk
