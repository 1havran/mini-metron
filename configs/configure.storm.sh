#!/bin/bash
rm -rf ap*
wget http://tux.rainside.sk/apache/storm/apache-storm-1.1.1/apache-storm-1.1.1.tar.gz
tar zxf ap*
cd ap*

./bin/storm ui&
./bin/storm nimbus&
./bin/storm supervisor&
