#!/bin/bash
cd
git clone https://github.com/apache/metron.git
cd metron
mvn clean package -DskipTests -Pbuild-rpms

echo '127.0.0.1 node1' >> /etc/hosts
echo 'listeners=PLAINTEXT://:6667' >> /home/kafka/kafka/config/server.properties

ln -s /home/storm/storm/bin/storm /usr/bin/storm
ln -s /home/zookeeper/zookeeper/bin/zkCli.sh /usr/bin/zookeeper-client
ln -sf /home/hadoop/hadoop/libexec/hadoop-config.sh /usr/libexec/

exit

squidclient -h localhost:3128 www.sme.sk
squidclient -h localhost:3128 www.pa1pal.com
cat /var/log/squid/access.log | /home/kafka/kafka_2.12-1.0.0/bin/kafka-console-producer.sh --topic squid --broker-list node1:6667
/home/kafka/kafka_2.12-1.0.0/bin/kafka-console-consumer.sh --topic squid --bootstrap-server node1:6667 --from-beginning
/home/kafka/kafka_2.12-1.0.0/bin/kafka-console-consumer.sh --topic enrichments --bootstrap-server node1:6667 --from-beginning
/home/kafka/kafka_2.12-1.0.0/bin/kafka-console-consumer.sh --topic indexing --bootstrap-server node1:6667 --from-beginning

