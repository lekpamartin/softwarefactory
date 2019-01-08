#!/bin/sh

PUSHGATEWAY_URL="http://user:password@HOSTNAME:PORT/metrics/job/purge"

DOCKER_DIR="/appli/docker"
SIZE="+250M"

PWD=`dirname $0`
TMP="$PWD/docker_monitoring_log_size.lock"

cd $DOCKER_DIR

CONTAINER=`find containers/*/*-json.log -type f -size $SIZE`

for i in $CONTAINER; do
        CONTAINER_ID=`echo $i | cut -d '/' -f2`
        CONTAINER_NAME=`docker inspect $CONTAINER_ID | grep -m 1 Name | cut -d '"' -f4 | cut -d '/' -f2`
        CONTAINER_SIZE=`ls -l $i | cut -d ' ' -f5`
        CONTAINER_IMAGE=`docker inspect $CONTAINER_NAME | grep -v sha256 | grep '"Image"' | cut -d '"' -f4`
	echo "docker_container_purge{instance=\"$HOSTNAME\",container_name=\"${CONTAINER_NAME}\",image=\"$CONTAINER_IMAGE\"} $CONTAINER_SIZE" >> $TMP

done

cat $TMP | curl --data-binary @- $PUSHGATEWAY_URL
rm -f $TMP
