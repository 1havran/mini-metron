#!/bin/bash
cd
git clone https://github.com/apache/metron.git
cd metron
mvn clean install -DskipTests -Pbuild-rpms
