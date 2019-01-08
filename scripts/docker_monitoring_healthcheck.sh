#!/bin/sh

TMP='/tmp/docker_monitoring_healthcheck.lock'
PUSHGATEWAY="http://user:password@HOSTNAME:PORT/metrics/job/healthcheck/instance/${HOSTNAME}"

for i in `docker ps -a --format '{{.Names}}'`; do STATUT=`docker inspect --format='{{.State.Health.Status}}' $i 2>&1`;
        case "$STATUT" in
                *unhealthy*)
                        echo "docker_healthcheck{name=\"$i\",status=\"unhealthy\"} 1" >> $TMP;;
                *healthy*)
                        echo "docker_healthcheck{name=\"$i\",status=\"healthy\"} 0" >> $TMP;;
                *Template*)
                        echo "docker_healthcheck{name=\"$i\",status=\"unavailable\"} 1" >> $TMP;;
                *)
                        echo "docker_healthcheck{name=\"$i\",status=\"unknown\"} 1" >> $TMP;;
        esac
done

cat $TMP | curl --data-binary @- $PUSHGATEWAY

rm -f $TMP
