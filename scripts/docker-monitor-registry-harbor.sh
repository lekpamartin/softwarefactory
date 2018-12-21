#!/bin/sh
#Version 0.1

CERT="-k"

HARBOR_API_USER=""
HARBOR_API_PASSWORD=""
HARBOR_NAME="harbor"
HARBOR_DOMAIN=""
HARBOR_URL="https://$HARBOR_DOMAIN"
HARBOR_API_URL="$HARBOR_URL/api"
HARBOR_PROJECT_ID="1 2"

CURLAPI="curl -s -u ${HARBOR_API_USER}:${HARBOR_API_PASSWORD} ${CERT} ${HARBOR_API_URL}"

PUSHGATEWAY_URL="http://login:password@HOSTNAME:PORT/metrics/job/registry"

TOUPDATE=""
NB=0
for i in $HARBOR_PROJECT_ID; do
	REPO_LIST=`$CURLAPI/repositories/?project_id=$i | jq -r '.[] | {name: .name  } | .name'`

	for j in $REPO_LIST; do
		TAGS=""
		OUTPUT_TAGS=`$CURLAPI/repositories/$j/tags | jq -r '.[] | {name: .name  } | .name'`
		TAGS="$TAGS $OUTPUT_TAGS"

		for k in $TAGS; do
			OUTPUT_VUL=`$CURLAPI/repositories/$j/tags/$k/vulnerability/details`
			FIXEDVERSION=`echo $OUTPUT_VUL | grep -o fixedVersion | wc -l`
			SEVERITY_HIGH=`echo $OUTPUT_VUL | grep -o '"severity": 5' | wc -l`
			SEVERITY_MEDIUM=`echo $OUTPUT_VUL | grep -o '"severity": 4' | wc -l`
			SEVERITY_LOW=`echo $OUTPUT_VUL | grep -co '"severity": 3' | wc -l`
			SEVERITY_UNKNOWN=`echo $OUTPUT_VUL | grep -o '"severity": 2' | wc -l`
			SEVERITY_NEGLIGIBLE=`echo $OUTPUT_VUL | grep -o '"severity": 1' | wc -l`
			repositories=`echo $j | sed "s./._.g"`

			cat << EOF | curl --data-binary @- ${PUSHGATEWAY_URL}/repositories/$repositories/tags/$k
docker_registry_vulnerability{instance="$HARBOR_NAME",repositories="$j",tags="$k",severity="HIGH"} $SEVERITY_HIGH
docker_registry_vulnerability{instance="$HARBOR_NAME",repositories="$j",tags="$k",severity="MEDIUM"} $SEVERITY_MEDIUM
docker_registry_vulnerability{instance="$HARBOR_NAME",repositories="$j",tags="$k",severity="LOW"} $SEVERITY_LOW
docker_registry_vulnerability{instance="$HARBOR_NAME",repositories="$j",tags="$k",severity="UNKNOWN"} $SEVERITY_UNKNOWN
docker_registry_vulnerability{instance="$HARBOR_NAME",repositories="$j",tags="$k",severity="NEGLIGIBLE"} $SEVERITY_NEGLIGIBLE
docker_registry_fixedVersion{instance="$HARBOR_NAME",repositories="$j",tags="$k"} $FIXEDVERSION
EOF
			NB=$(($NB + $FIXEDVERSION))
		done

	done
done
