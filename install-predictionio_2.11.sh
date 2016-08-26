#!/bin/bash

INSTALL_HOME="$HOME/usr/vendors"
PIO_HOME="$INSTALL_HOME/predictionio"
SPARK_HOME="$INSTALL_HOME/spark_2.11-1.6.2"
PIO_APP_NAME="EventServerAPI"
PIO_APP_ACCESSKEY="0UPlvV5KPiyS9AhA3fU791vmML9cMpzsrhKZc0E3a2Afe0AbB76JntjwSYixKNib"


mkdir $HOME/usr
mkdir $HOME/usr/vendors
mkdir $HOME/usr/vendors/predictionio

echo "Installing predictionio for 2_11..."
# bash -c "$(curl -s https://raw.githubusercontent.com/apache/incubator-predictionio/master/bin/install.sh)"
# bash -c "$(curl -s https://raw.githubusercontent.com/thib-s/incubator-predictionio/develop/bin/install.sh)"
mkdir tmp
cd tmp
TMP_DIR=pwd
echo "cloning git repository..."
git clone https://github.com/thib-s/incubator-predictionio.git 
git checkout develop
cd incubator-predictionio/bin
echo "running installation script..."
install.sh
echo "install finished."
cd $TMP_DIR
echo "recompiling spark binary...(needs mvn 3.3.3 to work correctly)"
git clone https://github.com/apache/spark.git
cd spark/
git checkout v1.6.2
./dev/change-scala-version.sh 2.11
./make-distribution.sh -Pyarn -Phadoop-2.4 -Dscala-2.11
echo "moving spark binary to pio vendor dir..."
mv dist/ $SPARK_HOME
cd $PIO_HOME/vendors/
mv spark-1.6.2/ spark-1.6.2_bck/
ln -s $SPARK_HOME spark-1.6.2

cd $TMP_DIR
cd ..
rm -r tmp/


echo "changing Elasticsearch port..."
sed -i -r 's/^# (PIO_STORAGE_SOURCES_ELASTICSEARCH_PORTS=)[0-9]+$/\19301/' $PIO_HOME/conf/pio-env.sh
sed -i -r 's/^# (PIO_STORAGE_SOURCES_ELASTICSEARCH_HOSTS=localhost)$/\1/' $PIO_HOME/conf/pio-env.sh
sed -i -r 's/^# (transport.tcp.port: )[0-9]+$/\19301/' $PIO_HOME/vendors/elasticsearch-1.7.5/config/elasticsearch.yml

echo "source from .profile"
source $HOME/.profile

echo "starting pio services (you will have to start it on each reboot)"
pio-start-all

echo "sleeping 10s for all services to fully initialize..."

echo "checking services status... (optional)"
pio status

echo "creating new application named $PIO_APP_NAME ..." 
#this line was not tested as it delete the events stored in the event server
pio app new --id 1 --access-key $PIO_APP_ACCESSKEY $PIO_APP_NAME

echo "installation finished, go to your engine directory and run pio build"
