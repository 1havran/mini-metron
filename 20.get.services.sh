#!/bin/bash

recipes_dir="./recipes"
services="hadoop-3.0.0 zookeeper-3.4.10 kafka-1.0.0 elasticsearch-6.1.1 storm-1.1.1"

for s in $services; do
	user=`echo $s | cut -d'-' -f1`
	userdel $user -r 
	adduser $user
	echo -e "$user\thard\tnofile\t32768" >> /etc/security/limits.d/$user
	echo -e "$user\tsoft\tnofile\t32768" >> /etc/security/limits.d/$user
	echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk" >> /home/$user/.bash_profile
	recipe="$s.sh"
	cp -v $recipes_dir/$recipe /home/$user/
	chmod 755 /home/$user/$recipe
	su - $user -c "/home/$user/$s.sh"
	sleep 10
	echo
done
