#!/bin/bash

rm -rf ~/zoo*
wget http://tux.rainside.sk/apache/zookeeper/stable/zookeeper-3.4.10.tar.gz; tar zxf zoo*
ln -sf zookeeper-3.4.10 zookeeper
cd zoo*
cp conf/zoo_sample.cfg conf/zoo.cfg
sed -i 's!dataDir=/tmp/zookeeper!dataDir=/home/zookeeper/zookeeper/dataDir!g' conf/zoo.cfg
echo 1 > /home/zookeeper/zookeeper/dataDir/myid
