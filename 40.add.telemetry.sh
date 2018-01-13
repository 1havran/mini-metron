#!/bin/bash

export ZK="node1:2181"
export ES="node1:9200"
export KAFKA="node1:6667"
export METRON_VERSION="0.4.3"
export HBASE_HOME="/home/hbase/hbase"

#check topic for source
/home/kafka/kafka/bin/kafka-topics.sh --list --zookeeper $ZK
# create indexing json
cat << EOF > /usr/metron/$METRON_VERSION/config/zookeeper/indexing/squid.json
{
   "elasticsearch": {  
      "index": "squid",  
      "batchSize": 5,
   "enabled" : true
   },
   "hdfs": {
 "index": "squid",  
  "batchSize": 5,
      "enabled" : true 
   }
EOF

cat << EOF > /usr/metron/$METRON_VERSION/config/zookeeper/global.json
{
  "es.clustername": "metron",
  "es.ip": "node1:9300",
  "es.date.format": "yyyy.MM.dd.HH",
  "parser.error.topic": "indexing",
  "update.hbase.table": "metron_update",
  "update.hbase.cf": "t",
  "fieldValidations" : [
   {
      "input" : [ "ip_src_addr", "ip_dst_addr" ],
      "validation" : "IP",
      "config" : {
      "type" : "IPV4"
       }
   }
  ]
}
EOF

/usr/metron/$METRON_VERSION/bin/geo_enrichment_load.sh -z $ZK
/usr/metron/$METRON_VERSION/bin/zk_load_configs.sh -i /usr/metron/$METRON_VERSION/config/zookeeper -m PUSH -z $ZK
storm kill squid
/usr/metron/$METRON_VERSION/bin/start_parser_topology.sh -k $KAFKA -z $ZK -s squid

service squid start
squidclient www.paypa1.com
cat /var/log/squid/access.log | /home/kafka/kafka/bin/kafka-console-producer.sh --topic squid --broker-list $KAFKA

curl 'localhost:9200/_cat/indices?v'

/home/kafka/kafka/bin/kafka-console-consumer.sh --topic squid --bootstrap-server $KAFKA --from-beginning
/home/kafka/kafka/bin/kafka-console-consumer.sh --topic enrichments --bootstrap-server $KAFKA --from-beginning
/home/kafka/kafka/bin/kafka-console-consumer.sh --topic indexing --bootstrap-server $KAFKA --from-beginning

