#!/bin/sh
#VERSION 0.1

CERT="-k"

TIMESTAMP=`date +%s`

DOCKER_URL="tcp://10.155.52.18:4243"
DOCKER_CMD="docker -H $DOCKER_URL"

PUSHGATEWAY_URL="http://user:password@HOSTNAME:PORT/metrics/job/registry"

PWD=`dirname $0`
TMP="$PWD/docker-monitor-container.lock"

if [ -e $TMP ]; then
        echo $TMP exist
        exit 1
fi

NB_CONTAINER_UP=`$DOCKER_CMD ps -q | wc -l`
NB_CONTAINER_EXITED=`$DOCKER_CMD ps -q --filter status=exited | wc -l`
NB_CONTAINER_CREATED=`$DOCKER_CMD ps -q --filter status=created | wc -l`

#Building docker_container
echo "docker_container{instance=\"status\",type=\"up\"} $NB_CONTAINER_UP
docker_container{instance=\"status\",type=\"exited\"} $NB_CONTAINER_EXITED
docker_container{instance=\"status\",type=\"created\"} $NB_CONTAINER_CREATED" >> $TMP

cat $TMP | curl --data-binary @- $PUSHGATEWAY_URL
rm -f $TMP
