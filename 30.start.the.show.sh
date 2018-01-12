#!/bin/bash
su - zookeeper -c "zook*/bin/zkServer.sh start"
su - kafka -c "kafka*/bin/kafka-server-start.sh -daemon config/server.properties &"
su - hdfs -c "hadoop/sbin/start-dfs.sh"
su - hdfs -c "hadoop/sbin/start-yarn.sh"
su - elasticsearch -c "elast*/bin/elasticsearch &"

echo 'Sleeping 30 seconds before Metron...'
sleep 30

export METRON_HOME="/usr/metron/4.3.0"
export HBASE_HOME="/home/hbase/hb*"

$METRON_HOME/bin/zk_load_configs.sh -m PUSH -i $METRON_HOME/config/zookeeper -z node1:2181
$METRON_HOME/bin/start_parser_topology.sh -k node1:6667 -z node1:2181 -s squid
$METRON_HOME/bin/start_enrichment_topology.sh
$METRON_HOME/bin/start_elasticsearch_topology.sh
$METRON_HOME/bin/start_profiler_topology.sh
storm list
