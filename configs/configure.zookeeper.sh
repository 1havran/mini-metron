rm -rf ~/zoo*
wget http://tux.rainside.sk/apache/zookeeper/stable/zookeeper-3.4.10.tar.gz; tar zxf zoo*
cd zoo*
cp conf/zoo_sample.cfg conf/zoo.cfg
bin/zkServer.sh start
