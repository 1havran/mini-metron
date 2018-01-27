#!/bin/bash
source /etc/default/metron

echo cleaning
rm -rf /tmp/kafka*
rm -rf /tmp/zookeepe*
rm -rf /tmp/hadoop*pid

echo zk on :2181
su - zookeeper -c "zookeeper/bin/zkServer.sh start"
sleep 10
echo kafka on :6667
su - kafka -c 'export KAFKA_HEAP_OPTS="-Xmx256m -Xms256m"; kafka/bin/kafka-server-start.sh -daemon kafka/config/server.properties &'

echo rsyslogd
/usr/sbin/rsyslogd

echo start splunk uf
/opt/splunkforwarder/bin/splunk start --accept-license
