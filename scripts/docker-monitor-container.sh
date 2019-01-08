#!/bin/sh
#VERSION 0.1

CERT="-k"

TIMESTAMP=`date +%s`

DOCKER_HOSTNAME="HOSTNAME"
DOCKER_URL="tcp://$DOCKER_HOSTNAME:PORT"
DOCKER_CMD="docker -H $DOCKER_URL"

PUSHGATEWAY_URL="http://user:password@HOSTNAME:PORT/metrics/job/docker/instance/$DOCKER_HOSTNAME"

PWD=`dirname $0`
TMP="$PWD/docker-monitor-container.lock"

if [ -e $TMP ]; then
        echo $TMP exist
        exit 1
fi

NB_CONTAINER_UP=`$DOCKER_CMD ps -q | wc -l`
NB_CONTAINER_EXITED=`$DOCKER_CMD ps -q --filter status=exited | wc -l`
NB_CONTAINER_CREATED=`$DOCKER_CMD ps -q --filter status=created | wc -l`
NB_CONTAINER_OUTDATED=`$DOCKER_CMD ps -aq | xargs -n 1 -r $DOCKER_CMD inspect -f '{{.Name}} {{.State.Running}} {{.State.StartedAt}}' | awk '$2 == "true" && $3 <= "'$(date -d '2 week ago' -Ins --utc | sed 's/+0000/Z/')'" { print $1 }' | wc -l`

#Building docker_container
echo "docker_container_status{type=\"up\"} $NB_CONTAINER_UP
docker_container_status{type=\"exited\"} $NB_CONTAINER_EXITED
docker_container_status{type=\"created\"} $NB_CONTAINER_CREATED
docker_container_status{type=\"outdated\"} $NB_CONTAINER_OUTDATED" >> $TMP

cat $TMP | curl --data-binary @- $PUSHGATEWAY_URL
rm -f $TMP
