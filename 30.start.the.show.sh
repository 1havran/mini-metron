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
echo hdfs dfs with hdfs:// on :9000
su - hadoop -c "hadoop/sbin/start-dfs.sh"
echo yarn on :8088
su - hadoop -c "hadoop/sbin/start-yarn.sh"
echo elasticsearch on :9200 and head on :9100
su - elasticsearch -c "elasticsearch/bin/elasticsearch -d &"
su - elasticsearch -c "cd plugin/elasticsearch-head && npm run start >/dev/null &"
echo kibana on :5601
su - kibana -c "kibana/bin/kibana serve &"
echo storm nimbus
su - storm -c "/home/storm/apache-storm/bin/storm nimbus >/dev/null &"
echo storm supervisor
su - storm -c "/home/storm/apache-storm/bin/storm supervisor >/dev/null &"
echo storm ui on :8080
su - storm -c "/home/storm/apache-storm/bin/storm ui >/dev/null &"
echo hbase master
su - hbase -c "/home/hbase/hbase/bin/hbase master start >/dev/null &"
echo hbase region
su - hbase -c "/home/hbase/hbase/bin/hbase regionserver start >/dev/null &"


echo 'Sleeping 30 seconds before Metron...'
sleep 30

echo metron
echo metron zk
$METRON_HOME/bin/zk_load_configs.sh -m PUSH -i $METRON_HOME/config/zookeeper -z $ZOOKEEPER
echo parser
$METRON_HOME/bin/start_parser_topology.sh -k $KAFKA -z $ZOOKEEPER -s squid >/dev/null
echo enrichment
$METRON_HOME/bin/start_enrichment_topology.sh >/dev/null
echo elasticsearch
$METRON_HOME/bin/start_elasticsearch_topology.sh >/dev/null
echo profiler
$METRON_HOME/bin/start_profiler_topology.sh >/dev/null
echo storm list
storm list
echo
echo elasticsearch indices
curl 'localhost:9200/_cat/indices?v'

echo start metron rest :8082/swagger-ui.html
$METRON_HOME/bin/metron-rest.sh
echo start metron alerts ui on :4200
$METRON_HOME/bin/metron-alerts-ui start
echo start metron management ui on :4201
$METRON_HOME/bin/metron-management-ui start
echo starting maas
$METRON_HOME/bin/maas_service.sh -zq $ZOOKEEPER >/dev/null


