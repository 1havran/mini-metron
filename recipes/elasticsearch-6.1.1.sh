#!/bin/bash
rm -rf ~/el*
java -version
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.1.1.tar.gz
tar zxf elastic*
ln -sf elasticsearch-6.1.1 elasticsearch
cd elast*
bin/elasticsearch &
