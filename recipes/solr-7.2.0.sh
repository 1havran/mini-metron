#!/bin/bash
rm -rf ~/sol*
java -version
wget http://tux.rainside.sk/apache/lucene/solr/7.2.0/solr-7.2.0.tgz
tar zxf solr*
ln -sf solr-7.2.0 solr
cd solr*
bin/solr start -c -z localhost:2181/solr720 &
