rm -rf kafka* 2>/dev/null
wget http://tux.rainside.sk/apache/kafka/1.0.0/kafka_2.12-1.0.0.tgz
tar zxf kafka*
cd kafka*
bin/kafka-server-start.sh -daemon config/server.properties
