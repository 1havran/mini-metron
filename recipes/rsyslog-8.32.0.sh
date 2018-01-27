#!/bin/bash
cd ~
killall rsyslogd
yum remove rsyslog
rm -rf rsyslog* libestr* libfastjson* liblogging* librdkafka

yum install git valgrind autoconf automake flex bison python-docutils python-sphinx json-c-devel libuuid-devel libgcrypt-devel zlib-devel openssl-devel libcurl-devel gnutls-devel mysql-devel postgresql-devel libdbi-dbd-mysql libdbi-devel net-snmp-devel

wget http://www.rsyslog.com/files/download/rsyslog/rsyslog-8.32.0.tar.gz
wget http://libestr.adiscon.com/files/download/libestr-0.1.10.tar.gz
wget http://download.rsyslog.com/libfastjson/libfastjson-0.99.8.tar.gz
wget http://download.rsyslog.com/liblogging/liblogging-1.0.6.tar.gz
git clone https://github.com/edenhill/librdkafka.git

tar zxf rsyslog*
tar zxf libestr*
tar zxf libfastjson*
tar zxf liblogging*

cd libestr* && ./configure --libdir=/usr/lib64 --includedir=/usr/include && make && make install
cd libfastjson* && ./configure --libdir=/usr/lib64 --includedir=/usr/include && make && make install
cd liblogging* && ./configure  --libdir=/usr/lib64 --includedir=/usr/include && make && make install
cd librdkafka && ./configure  --libdir=/usr/lib64 --includedir=/usr/include && make && make install
cd rsyslog* && ./configure --enable-omkafka && make && make install

for i in 50001 50002; do
cat << EOF > /etc/rsyslog.d/$i.conf
\$RulesetCreateMainQueue on
\$ModLoad imudp
\$ModLoad imtcp

input(type="imudp" port="$i" ruleset="rule-$i")
input(type="imtcp" port="$i" ruleset="rule-$i")

ruleset(name="rule-$i") {
        \$ModLoad omkafka
        action(type="omkafka" topic="bucket-$i" confParam="compression.codec=snappy"
                broker="localhost:6667" resubmitOnFailure="on")
        stop
}
EOF
done

