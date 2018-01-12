#!/bin/bash
cd
wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
curl -sL https://rpm.nodesource.com/setup_6.x | sudo -E bash -
yum install -y nodejs --enablerepo=nodesource
yum install -y git tmux maven java-1.8.0-openjdk java-1.8.0-openjdk-devel
update-alternatives --config java
update-alternatives --config javac
