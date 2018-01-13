#!/bin/bash
cd
git clone https://github.com/apache/metron.git
cd metron
git checkout 2dd01b17782af7756776b8e07afe3661ac19bb0a
mvn clean package -DskipTests -Pbuild-rpms
cd metron-deployment/packaging/docker/rpm-docker/RPMS/noarch/
rpm -Uvh metron*rpm

echo '127.0.0.1 node1' >> /etc/hosts
echo 'listeners=PLAINTEXT://:6667' >> /home/kafka/kafka/config/server.properties
sed -i "s/topology.auto-credentials=['']/topology.auto-credentials=/g" /usr/metron/*/config/elasticsearch.properties
echo 'cluster.name: metron' >> /home/elasticsearch/elasticsearch/config/elasticsearch.yml

ln -s /home/storm/storm/bin/storm /usr/bin/storm
ln -s /home/zookeeper/zookeeper/bin/zkCli.sh /usr/bin/zookeeper-client
ln -sf /home/hadoop/hadoop/libexec/hadoop-config.sh /usr/libexec/


cd /root/metron/metron-deployment/packaging/ambari/metron-mpack/target/classes/common-services/METRON/CURRENT/package/files
for i in *template; do
	ii=`echo $i | cut -d_ -f1`
	index=$ii"_index"
	curl -XPUT "http://node1:9200/_template/$index" -d @$i
done
