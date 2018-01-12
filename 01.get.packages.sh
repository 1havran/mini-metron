#!/bin/bash
cd /usr/src
wget https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.zip
tar xzf apache-maven-3.3.9*
mv apache-maven-3.3.9 /opt/maven
ln -s /opt/maven/bin/mvn /usr/bin/mvn

curl -sL https://rpm.nodesource.com/setup_6.x | sudo -E bash -
yum install -y nodejs --enablerepo=nodesource
yum install -y git tmux java-1.8.0-openjdk java-1.8.0-openjdk-devel gcc gcc-c++ tar docker
yum remove -y java-1.7.0
npm install -g node-gyp

yum clean all
service docker start
