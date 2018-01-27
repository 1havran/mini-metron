#!/bin/bash
source /etc/default/metron

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

cat << EOF > /usr/metron/$METRON_VERSION/config/zookeeper/enrichments/squid.json
{
  "threatIntel": {
    "fieldMap": {
      "stellar" : {
        "config" : [
          "is_alert := domain_without_subdomains == 'paypa1.com'"
        ]
      }
    },
    "fieldToTypeMap": { },
    "triageConfig" : {
      "riskLevelRules" : [
        {
          "name" : "Paypa1 alert",
          "rule" : "is_alert != null",
          "comment" : "no comment",
          "score" : 10,
          "reason" : "testing"
        }
      ],
      "aggregator" : "MAX"
    }
  }
}
EOF

echo "" && echo loading configs to ZK && sleep 5
/usr/metron/$METRON_VERSION/bin/zk_load_configs.sh -i /usr/metron/$METRON_VERSION/config/zookeeper -m PUSH -z $ZK

#/home/kafka/kafka/bin/kafka-console-consumer.sh --topic squid --bootstrap-server $KAFKA --from-beginning
#/home/kafka/kafka/bin/kafka-console-consumer.sh --topic enrichments --bootstrap-server $KAFKA --from-beginning
#/home/kafka/kafka/bin/kafka-console-consumer.sh --topic indexing --bootstrap-server $KAFKA --from-beginning

