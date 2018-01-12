#!/bin/bash

conf_dir="./configs"
services="hdfs zookeeper kafka elasticsearch metron"
services="hdfs"
for i in $services; do
	adduser $i
	echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> /home/$i/.bash_profile
	conf="$conf_dir/configure.$i.sh"
	cp $conf /home/$i
	chmod 755 /home/$i/$conf
	su - $i -c "/home/$i/$conf"
done
