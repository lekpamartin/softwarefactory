#!/bin/sh
#VERSION 0.1

CERT="-k"

HARBOR_API_USER=""
HARBOR_API_PASSWORD=""
HARBOR_NAME="harbor"
HARBOR_DOMAIN=""
HARBOR_URL="https://$HARBOR_DOMAIN"
HARBOR_API_URL="$HARBOR_URL/api"
HARBOR_PROJECT_ID="1 2"

DOCKER_URL="tcp://HOSTNAME:PORT"
DOCKER_CMD="docker -H $DOCKER_URL"

PUSHGATEWAY_URL="http://user:password@HOSTNAME:PORT/metrics/job/registry"

CURLAPI="curl -s -u ${HARBOR_API_USER}:${HARBOR_API_PASSWORD} ${CERT} ${HARBOR_API_URL}"

PWD=`dirname $0`
TMP="$PWD/docker-monitor-image-harbor.lock"

if [ -e $TMP ]; then
	echo $TMP exist
	exit 1
fi

NB_IMAGES_DANGLING=`$DOCKER_CMD images -f dangling=true -q | wc -l`
for i in `$DOCKER_CMD ps -a |  grep -v "$HARBOR_DOMAIN" | awk -F " " '{ print $2 }' | grep -v ID`; do
	$DOCKER_CMD inspect  --format='{{.RepoDigests}}' $i 2>/dev/null | grep -q "$HARBOR_DOMAIN"
	if [ "$?" != 0 ]; then
		NB_IMAGES_OTHER=$((NB_IMAGES_OTHER + 1))
	fi
done

USED_IMAGES=`$DOCKER_CMD ps -a --format '{{.Image}}' | grep "$HARBOR_DOMAIN"`
NB_USED_IMAGES_OBSOLETE=0
for i in $USED_IMAGES; do
	SHORTNAME=`echo $i | sed "s/$HARBOR_DOMAIN//g"`
	REPOSITORY=`echo $SHORTNAME | cut -d ":" -f1`
	REPOSITORY2=`echo $REPOSITORY | sed 's./._.g'`
	TAG=`echo $SHORTNAME | awk -F ":" '{ print $2 }'`
	USED_IMAGES_CREATIONDATE=`$DOCKER_CMD inspect $i --format '{{.Created}}'`
	USED_IMAGES_UPDATEDATE=`$CURLAPI/repositories/$REPOSITORY/tags/${TAG:-latest} | grep "created" | cut -d '"' -f4`
	if [ "$USED_IMAGES_CREATIONDATE" != "$USED_IMAGES_UPDATEDATE" ]; then
		NB_USED_IMAGES_OBSOLETE=$((NB_USED_IMAGES_OBSOLETE+1))
		echo "docker_container_to_run{instance=\"$HARBOR_NAME\",type=\"toruncontainer\",repository=\"${REPOSITORY2}\",tag=\"${TAG:-latest}\"} 1" >> $TMP
	fi
done

#Building docker_image
eco "docker_image{instance=\"$HARBOR_NAME\",type=\"dangling\"} $NB_IMAGES_DANGLING
docker_image{instance=\"$HARBOR_NAME\",type=\"other_registry\"} $NB_IMAGES_OTHER
docker_image{instance=\"$HARBOR_NAME\",type=\"runcontainer\"} $NB_USED_IMAGES_OBSOLETE" >> $TMP

cat $TMP | curl --data-binary @- $PUSHGATEWAY_URL
rm -f $TMP
