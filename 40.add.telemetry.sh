#!/bin/bash

export ZK="node1:2181"
export ES="node1:9200"
export KAFKA="node1:6667"
export METRON_VERSION="0.4.3"
export HADOOP_HOME="/home/hadoop/hadoop"
export HBASE_HOME="/home/hbase/hbase"

#check topic for source
echo checking kafka topics
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

echo "" && echo updating geoip information && sleep 5
/usr/metron/$METRON_VERSION/bin/geo_enrichment_load.sh -z $ZK
echo "" && echo loading configs to ZK && sleep 5
/usr/metron/$METRON_VERSION/bin/zk_load_configs.sh -i /usr/metron/$METRON_VERSION/config/zookeeper -m PUSH -z $ZK
echo "" && echo killing squid topology && sleep 5
storm kill squid
sleep 10
echo "" && echo starting squid topology
/usr/metron/$METRON_VERSION/bin/start_parser_topology.sh -k $KAFKA -z $ZK -s squid

echo "" && echo starting squid proxy
service squid start

echo "" && echo reaching to www.paypa1.com
squidclient www.paypa1.com 2>/dev/null
cat /var/log/squid/access.log | /home/kafka/kafka/bin/kafka-console-producer.sh --topic squid --broker-list $KAFKA

echo "" && echo elasticsearch indexes
curl 'localhost:9200/_cat/indices?v'
echo "Search in ES or Head plugin http://localhost:9100 for payla1.com in squid log!"

#/home/kafka/kafka/bin/kafka-console-consumer.sh --topic squid --bootstrap-server $KAFKA --from-beginning
#/home/kafka/kafka/bin/kafka-console-consumer.sh --topic enrichments --bootstrap-server $KAFKA --from-beginning
#/home/kafka/kafka/bin/kafka-console-consumer.sh --topic indexing --bootstrap-server $KAFKA --from-beginning

