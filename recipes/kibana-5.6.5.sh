#!/bin/bash
rm -rf kibana* 2>/dev/null
wget https://artifacts.elastic.co/downloads/kibana/kibana-5.6.5-linux-x86_64.tar.gz
tar zxf kibana*
ln -sf kibana-5.6.5-linux-x86_64 kibana
