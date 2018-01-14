#!/bin/bash
source /etc/default/metron

echo cleaning
rm -rf /tmp/kafka*
rm -rf /tmp/zookeepe*
rm -rf /tmp/hadoop*pid

echo zk
su - zookeeper -c "zookeeper/bin/zkServer.sh start"
echo kafka
su - kafka -c 'export KAFKA_HEAP_OPTS="-Xmx256m -Xms256m"; kafka/bin/kafka-server-start.sh -daemon kafka/config/server.properties &'
echo hdfs dfs
su - hadoop -c "hadoop/sbin/start-dfs.sh"
echo yarn
su - hadoop -c "hadoop/sbin/start-yarn.sh"
echo elasticsearch
su - elasticsearch -c "elasticsearch/bin/elasticsearch -d &"
su - elasticsearch -c "cd plugin/elasticsearch-head && npm run start &"
echo kibana
su - kibana -c "kibana/bin/kibana serve &"
echo storm nimbus
su - storm -c "/home/storm/apache-storm/bin/storm nimbus 2>/dev/null &"
echo storm supervisor
su - storm -c "/home/storm/apache-storm/bin/storm supervisor 2>/dev/null &"
echo storm ui
su - storm -c "/home/storm/apache-storm/bin/storm ui 2>/dev/null &"
echo hbase master
su - hbase -c "/home/hbase/hbase/bin/hbase master start &"
echo hbase region
su - hbase -c "/home/hbase/hbase/bin/hbase regionservert start &"


echo 'Sleeping 30 seconds before Metron...'
sleep 30

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
echo storm list
storm list
echo
echo elasticsearch indices
curl 'localhost:9200/_cat/indices?v'
