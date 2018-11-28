#!/bin/sh

ACTION=$1
WORKINGDIR=`dirname $0`

if [ "$ACTION" == "" ]; then
	echo -en "\n\t $0 up|down\n\n"
	exit 
fi 

echo -en "\n\t Softwarefactory building \n\n\t Login : " 
read ADMIN_USER
echo -en "\t Password : "
read -s ADMIN_PASSWORD

cd $WORKINGDIR

#Loading configuration
. ./softwarefactory.conf

case $ACTION in
	up|Up|UP)
		echo -en "\n\n\t * Running infra\n"
		docker-compose up -d

		#HARBOR configuration
		if [ "$HARBOR_ENABLE" == "yes" ]; then
			echo -en "\n\n\t * Harbor is enabled"
			if [ -e harbor ]; then
				echo -en "\n\t\t - Harbor already exist"
			else
				echo -en "\n\t\t - Getting sources (v$HARBOR_VERSION)\n"
				wget -q https://storage.googleapis.com/harbor-releases/release-$HARBOR_RELEASE/harbor-$HARBOR_TYPE-installer-v$HARBOR_VERSION.tgz
				tar xvf harbor-$HARBOR_TYPE-installer-v$HARBOR_VERSION.tgz
				rm -f harbor-$HARBOR_TYPE-installer-v$HARBOR_VERSION.tgz
			fi
			cd harbor
			echo -en "\n\t\t - Running (${HARBOR_SERVICES})\n"
			sed -i "s/ui_url_protocol = http$/ui_url_protocol = https/g" harbor.cfg
			./install.sh ${HARBOR_SERVICES}
			cd -
		else
			echo -e "\n\n\t * Harbor is disabled"
		fi

		#SONARQUBE configuration
		if [ "$SONARQUBE_ENABLE" == "yes" ]; then
			echo -en "\n\n\t * SONARQUBE is enabled"
			docker-compose -f docker-compose-sonarqube.yml up -d
		else
			echo -e "\n\n\t * SONARQUBE is disabled"
		fi

	;;
	down|Down|DOWN)
		echo -en "\n\n\t - Building infra"
		docker-compose down
		cd harbor
		docker-compose down
	;;
	destroy)
		echo -en "\n\n\t - Destroying infra"
		docker-compose down -v
		cd harbor; docker-compose down -v
		rm -rf /data/database rm -r /data/registry
	;;
esac
