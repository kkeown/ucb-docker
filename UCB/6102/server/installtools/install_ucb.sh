#!/bin/bash
# usage install_ucb.sh URL
# install the ucb from a zip that can be found at an http url.  See the Dockerfile for this line:
# RUN /installtools/install_ucb.sh $UCB_SERVER_ZIP

set -x

URL=$1
pushd /

# get and unzip the ucb installer
FILE=$(basename $URL)

trap 'rm -rf $FILE /ibm-ucb-install' EXIT
if [ ! -f $FILE ]; then
    echo "curl -sS -O $URL"
    curl -sS -O $URL
fi
# This creates /ibm-ucb-install
unzip -q $FILE

# install ucb and remove the installer
cd ibm-ucb-install

dockerhost=$(ip route | awk '/default/ { print $3 }')
case ${IBM_UCB_SECURE,,} in
    true)
        always_secure=Y
        web_url=https://$dockerhost:8443
        mutualAuth=y
        ;;
    false)
        always_secure=n
        web_url=http://$dockerhost:8080
        mutualAuth=n
        ;;
    *)  echo "IBM_UCB_SECURE must be true or false, not '$IBM_UCB_SECURE'"
        exit 1
esac

cat >> install.properties <<EOF
nonInteractive=true
install.accept.license=Y
install.server.key.password=pbe{zVYMZedUPGG7Td5W4FukZZnGneXmJXccq73TH4VOzrg\=}
install.server.keystore=../conf/server.keystore
install.server.db.user=ibm_ucb
install.server.brokerUrl=failover\:(ah3\://localhost\:7919?soTimeout\=60000&daemon\=true)
server.keystore=../conf/server.keystore
install.server.web.port=8080
install.server.web.always.secure=$always_secure
install.server.keystore.password=pbe{/WD3YbBPMFkhZpZRpmb4W/2FQBZxFbDggTFfPCPcBSM\=}
install.server.db.type=derby
install.server.web.https.port=8443
install.server.web.host=localhost
install.server.jms.port=7919
install.java.home=/opt/java/ibm/java-x86_64-80/jre
install.server.brokerConfigUrl=xbean\:activemq.xml
install.server.db.url=jdbc\:derby\://localhost\:11378/data
install.server.startBroker=false
install.server.web.ip=0.0.0.0
install.server.db.password=pbe{zla2a/5UQmcXV4Vnm1c1aRJJn/+QJY7Hh8CgDyagAP4\=}
install.server.db.no.create.tables=N
install.server.external.web.url=$web_url
install.server.db.driver=org.apache.derby.jdbc.ClientDriver
install.server.db.derby.port=11378
install.server.launchBrokerProcess=true
install.rcl.server=null
install.server.jms.mutualAuth=true
java.io.tmpdir=/opt/IBM/UCBuild/server/var/temp
install.server.db.validationQuery=values(1)
EOF

sleep 5s
./install-server.sh > install-server.log 2>&1

