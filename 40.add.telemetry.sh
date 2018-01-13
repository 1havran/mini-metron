#!/bin/bash

ZK="node1:2181"
ES="node1:9200"
KAFKA="node1:6667"
METRON_VERSION="0.4.3"

curl -XPOST $ES/_template/squid_index -d '
 {
 "template": "squid_index*",
 "mappings": {
 "squid_doc": {
 "properties": {
 "timestamp": {
 "type": "date",
 "format": "epoch_millis"
 },
 "source:type": {
 "type": "string",
 "index": "not_analyzed"
 },
 "action": {
 "type": "string",
 "index": "not_analyzed"
 },
 "bytes": {
 "type": "integer"
 },
 "code": {
 "type": "string",
 "index": "not_analyzed"
 },
 "domain_without_subdomains": {
 "type": "string",
 "index": "not_analyzed"
 },
 "full_hostname": {
 "type": "string",
 "index": "not_analyzed"
 },
 "elapsed": {
 "type": "integer"
 },
 "method": {
 "type": "string",
 "index": "not_analyzed"
 },
 "ip_dst_addr": {
 "type": "string",
 "index": "not_analyzed"
 }
 }
 }
 }
 }'

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
   "hdfs"" {
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
/usr/metron/$METRON_VERSION/bin/zk_load_configs.sh -i /usr/metron/$METRON_VERSION/config/zookeeper -m PUSH -z $ZK
storm kill squid
/usr/metron/$METRON_VERSION/bin/start_parser_topology.sh -k $KAFKA -z $ZK -s squid

service squid start
squidclient www.paypa1.com
cat /var/log/squid/access.log | /home/kafka/kafka_2.12-1.0.0/bin/kafka-console-producer.sh --topic squid --broker-list $KAFKA

curl 'localhost:9200/_cat/indices?v'

/home/kafka/kafka_2.12-1.0.0/bin/kafka-console-consumer.sh --topic squid --bootstrap-server $KAFKA --from-beginning
/home/kafka/kafka_2.12-1.0.0/bin/kafka-console-consumer.sh --topic enrichments --bootstrap-server $KAFKA --from-beginning
/home/kafka/kafka_2.12-1.0.0/bin/kafka-console-consumer.sh --topic indexing --bootstrap-server $KAFKA --from-beginning

