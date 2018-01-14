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
echo http.cors.enabled: true >> /home/elasticsearch/elasticsearch/config/elasticsearch.yml
echo http.cors.allow-origin: /.* >> /home/elasticsearch/elasticsearch/config/elasticsearch.yml
sed -i "s/-Xms2g/-Xms512m/g" /home/elasticsearch/elasticsearch/config/jvm.options
sed -i "s/-Xmx2g/-Xmx512m/g" /home/elasticsearch/elasticsearch/config/jvm.options
echo "supervisor.slots.ports: [6700, 6701, 6702, 6703, 6704, 6705]" >> /home/storm/storm/conf/storm.yaml
su - hadoop -c "hadoop/bin/hadoop dfs -mkdir /hbase"
su - hadoop -c "hadoop/bin/hadoop dfs -chown hbase /hbase"

ln -s /home/storm/storm/bin/storm /usr/bin/storm
ln -s /home/zookeeper/zookeeper/bin/zkCli.sh /usr/bin/zookeeper-client
ln -sf /home/hadoop/hadoop/libexec/hadoop-config.sh /usr/libexec/
ln -sf /home/hadoop/hadoop/bin/hadoop /usr/bin/

cd /root/metron/metron-deployment/packaging/ambari/metron-mpack/target/classes/common-services/METRON/CURRENT/package/files
for i in *template; do
	ii=`echo $i | cut -d_ -f1`
	index=$ii"_index"
	curl -XPUT "http://node1:9200/_template/$index" -d @$i
done


cat <<EOF > /etc/default/metron
METRON_JDBC_DRIVER="org.h2.Driver"
METRON_JDBC_URL="jdbc:h2:file:~/metrondb"
METRON_JDBC_USERNAME="root"
METRON_JDBC_PLATFORM="h2"
METRON_JDBC_PASSWORD="root"
HDFS_URL="hdfs://localhost:9000"
ZOOKEEPER="localhost:2181"
ZK=\$ZOOKEEPER
BROKERLIST="localhost:6667"
KAFKA=\$BROKERLIST
METRON_SPRING_PROFILES_ACTIVE="vagrant,dev"
SECURITY_ENABLED="false

HADOOP_HOME="/home/hadoop/hadoop"
METRON_HOME="/usr/metron/0.4.3"
HBASE_HOME="/home/hbase/hbase"
JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk"
EOF
