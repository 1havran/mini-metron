#!/bin/bash
rm -rf kafka* 2>/dev/null
wget http://tux.rainside.sk/apache/kafka/1.0.0/kafka_2.12-1.0.0.tgz
tar zxf kafka*
ln -sf kafka_2.12-1.0.0 kafka
echo >> /home/kafka/kafka/config/server.properties
echo 'listeners=PLAINTEXT://:6667' >> /home/kafka/kafka/config/server.properties
