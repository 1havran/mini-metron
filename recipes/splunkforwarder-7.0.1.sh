#!/bin/bash
wget -O splunkforwarder-7.0.1-2b5b15c4ee89-linux-2.6-x86_64.rpm 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.0.1&product=universalforwarder&filename=splunkforwarder-7.0.1-2b5b15c4ee89-linux-2.6-x86_64.rpm&wget=true'

rpm -Uvh splunkforwarder-7.0.1-2b5b15c4ee89-linux-2.6-x86_64.rpm
cat << EOF > /opt/splunkforwarder/etc/system/local/inputs.conf
[monitor:///var/log/secure]
sourcetype = linux_secure
ignoreOlderThan = 1h

[monitor://\$SPLUNK_HOME/var/log/splunk/metrics.log]
disabled = true

[monitor://\$SPLUNK_HOME/var/log/splunk/splunkd.log]
disabled = true

[monitor://\$SPLUNK_HOME/var/log/splunk]
disabled = true
EOF

cat <<EOF > /opt/splunkforwarder/etc/system/local/outputs.conf
[tcpout]
defaultGroup = rsyslogKafkaTcp, rsyslogKafkaUdp
sendCookedData = false
forwardedindex.0.whitelist = .*
forwardedindex.1.whitelist = .*
forwardedindex.2.whitelist = .*

[tcpout:rsyslogKafkaTcp]
server = localhost:50001
type = tcp
EOF

/opt/splunkforwarder/bin/splunk status --accept-license
