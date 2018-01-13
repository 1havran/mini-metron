#!/bin/bash
rm -rf hb*
wget http://tux.rainside.sk/apache/hbase/stable/hbase-1.2.6-bin.tar.gz
tar zxf hb*
ln -sf hbase-1.2.6 hbase
cd hb*
