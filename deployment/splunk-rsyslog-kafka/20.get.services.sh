#!/bin/bash

recipes_dir="../../recipes"
services="zookeeper-3.4.10 kafka-1.0.0"
root_services="rsyslog-8.32.0 splunkforwarder-7.0.1"

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

for s in $root_services; do
	sh $recipes_dir/$s.sh
done
