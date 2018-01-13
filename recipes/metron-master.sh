#!/bin/bash
cd
git clone https://github.com/apache/metron.git
cd metron
mvn clean package -DskipTests -Pbuild-rpms
cd metron-deployment/packaging/docker/rpm-docker/RPMS/noarch/
rpm -Uvh metron*rpm

echo '127.0.0.1 node1' >> /etc/hosts
echo 'listeners=PLAINTEXT://:6667' >> /home/kafka/kafka/config/server.properties
sed -i "s/topology.auto-credentials=['']/topology.auto-credentials=/g" /usr/metron/*/config/elasticsearch.properties

ln -s /home/storm/storm/bin/storm /usr/bin/storm
ln -s /home/zookeeper/zookeeper/bin/zkCli.sh /usr/bin/zookeeper-client
ln -sf /home/hadoop/hadoop/libexec/hadoop-config.sh /usr/libexec/

exit
