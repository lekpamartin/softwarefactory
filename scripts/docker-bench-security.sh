#!/bin/sh

PUSHGATEWAY_URL="http://user:password@localhost:9091/metrics/job/dockerbench"

cd /tmp
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security
sh docker-bench-security.sh

LOG="test.log"
> $LOG
FILE="docker-bench-security.sh.log.json"
VERSION=$(jq -r '.dockerbenchsecurity' $FILE)
for i in $(jq -r '.tests[].id' $FILE); do
	TESTID=$(($i-1))
	NAME=$(jq -r ".tests[$TESTID].desc" docker-bench-security.sh.log.json)
	for j in $(jq -r ".tests[$TESTID].results[] | select(.result==\"WARN\") | .id" docker-bench-security.sh.log.json); do
		DESC=$(jq -r ".tests[$TESTID].results[] | select(.id==\"$j\") | .desc" docker-bench-security.sh.log.json)
		DETAILS=$(jq -r ".tests[$TESTID].results[] | select(.id==\"$j\") | .details" docker-bench-security.sh.log.json)
		echo "dockerbenchsecurity{version=\"$VERSION\",instance=\"$NAME\",id=\"$j\",name=\"$DESC\",details=\"$DETAILS\"} 1" >> $LOG
	done
done

cat $LOG | curl --data-binary @- $PUSHGATEWAY_URL
cd ..
rm -fr docker-bench-security
