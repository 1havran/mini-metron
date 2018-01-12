#!/bin/bash

conf_dir="./configs"
services="hdfs zookeeper kafka elasticsearch metron storm"
for i in $services; do
	adduser $i
	echo -e "$i\thard\tnofile\t32768" >> /etc/security/limits.d/$i
	echo -e "$i\tsoft\tnofile\t32768" >> /etc/security/limits.d/$i
	echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> /home/$i/.bash_profile
	conf="$conf_dir/configure.$i.sh"
	cp $conf /home/$i
	chmod 755 /home/$i/$conf
	su - $i -c "/home/$i/$conf"
done
