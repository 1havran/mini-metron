#!/bin/bash
echo cleaning
rm -rf /tmp/kafka*
rm -rf /tmp/zookeepe*
rm -rf /tmp/hadoop*pid

echo zk
su - zookeeper -c "zookeeper/bin/zkServer.sh start"
echo kafka
su - kafka -c "kafka/bin/kafka-server-start.sh -daemon kafka/config/server.properties &"
echo hdfs dfs
su - hdfs -c "hadoop/sbin/start-dfs.sh"
echo yarn
su - hdfs -c "hadoop/sbin/start-yarn.sh"
echo elasticsearch
su - elasticsearch -c "elasticsearch/bin/elasticsearch -d &"
echo storm nimbus
su - storm -c "/home/storm/apache-storm/bin/storm nimbus 2>/dev/null &"
echo storm supervisor
su - storm -c "/home/storm/apache-storm/bin/storm supervisor 2>/dev/null &"
echo storm ui
su - storm -c "/home/storm/apache-storm/bin/storm ui 2>/dev/null &"

echo 'Sleeping 30 seconds before Metron...'
sleep 30

export METRON_HOME="/usr/metron/0.4.3"
export HBASE_HOME="/home/hbase/hbase"
export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk"

echo metron
echo metron zk
$METRON_HOME/bin/zk_load_configs.sh -m PUSH -i $METRON_HOME/config/zookeeper -z node1:2181
echo parser
$METRON_HOME/bin/start_parser_topology.sh -k node1:6667 -z node1:2181 -s squid
echo enrichment
$METRON_HOME/bin/start_enrichment_topology.sh
echo elasticsearch
$METRON_HOME/bin/start_elasticsearch_topology.sh
echo profiler
$METRON_HOME/bin/start_profiler_topology.sh
storm list
curl 'localhost:9200/_cat/indices?v'
