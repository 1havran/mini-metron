#!/bin/bash
rm -rf kibana* 2>/dev/null
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.1.1-linux-x86_64.tar.gz
tar zxf kibana*
ln -sf kiban-6.1.1-linux-x86_64 kibana
