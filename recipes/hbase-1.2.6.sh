#!/bin/bash
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys

rm -rf hb*
wget http://tux.rainside.sk/apache/hbase/stable/hbase-1.2.6-bin.tar.gz
tar zxf hb*
ln -sf hbase-1.2.6 hbase
cd hb*
echo export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk >> conf/hbase-env.sh
echo export HBASE_MANAGES_ZK=false >> conf/hbase-env.sh
echo localhost > conf/regionservers

cat << EOF > conf/hbase-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://localhost:9000/hbase</value>
  </property>
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>
</configuration>
EOF

