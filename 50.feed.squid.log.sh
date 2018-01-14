#!/bin/bash
source /etc/default/metron

if ! `service squid status >/dev/null`; then
	service squid start
fi

echo
echo "URL that ends with paypa1.com are evaluated as alerts"
echo -en "    Type url [aaa.bbb.ccc.ddd.paypa1.com]: "
read url

if [ "x$url" == "x" ]; then
	url="aaa.bbb.ccc.ddd.paypa1.com"
fi

squidclient -s $url && tail -n 1 /var/log/squid/access.log | /home/kafka/kafka/bin/kafka-console-producer.sh --topic squid --broker-list $KAFKA

echo "" && echo elasticsearch indexes
curl "$ES/_search?q=url:\"$url\"&pretty"

#/home/kafka/kafka/bin/kafka-console-consumer.sh --topic squid --bootstrap-server $KAFKA --from-beginning
#/home/kafka/kafka/bin/kafka-console-consumer.sh --topic enrichments --bootstrap-server $KAFKA --from-beginning
#/home/kafka/kafka/bin/kafka-console-consumer.sh --topic indexing --bootstrap-server $KAFKA --from-beginning

