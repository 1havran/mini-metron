#!/bin/bash
rm -rf ~/el*
java -version
wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.4.2/elasticsearch-2.4.2.tar.gz
tar zxf elastic*
ln -sf elasticsearch-2.4.2 elasticsearch
cd elast*
bin/plugin -v install mobz/elasticsearch-head
bin/elasticsearch &

