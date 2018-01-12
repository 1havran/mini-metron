#!/bin/bash

conf_dir="./recipes"
services="hdfs zookeeper kafka elasticsearch storm"
services="elasticsearch"
for i in $services; do
	echo -e "$i\thard\tnofile\t32768" >> /etc/security/limits.d/$i
	echo -e "$i\tsoft\tnofile\t32768" >> /etc/security/limits.d/$i
	echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> /home/$i/.bash_profile
	conf="$i*.sh"
	cp $conf_dir/$conf /home/$i
	chmod 755 /home/$i/$conf
	su - $i -c "/home/$i/*sh"
done
