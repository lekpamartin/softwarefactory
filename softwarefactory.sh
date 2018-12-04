#!/bin/sh

ACTION=$1
WORKINGDIR=`dirname $0`

if [ "$ACTION" == "" ]; then
	echo -e "\n\t $0 up|down\n\n"
	exit 
fi 

echo -e "\n\t SOFTWARE FACTORY" 

cd $WORKINGDIR

#Loading configuration
. ./softwarefactory.conf

case $ACTION in
	up|Up|UP)
		echo -en "\n\n\t * Running base infra\n"
		docker-compose up -d

		#GITLAB configuration
		if [ "$GITLAB_ENABLE" == "yes" ]; then
			echo -e "\n\n\t * Gitlab is enabled\n"
			docker-compose -f docker-compose-gitlab.yml up -d	
		fi

		#HARBOR configuration
		if [ "$HARBOR_ENABLE" == "yes" ]; then
			echo -e "\n\n\t * Harbor is enabled\n"
			if [ -e harbor ]; then
				echo -e "\n\t\t - Harbor already exist"
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
			echo -e "\n\n\t * Harbor is disabled\n"
		fi

		#SONARQUBE configuration
		if [ "$SONARQUBE_ENABLE" == "yes" ]; then
			echo -en "\n\n\t * SONARQUBE is enabled\n"
			docker-compose -f docker-compose-sonarqube.yml up -d
		else
			echo -e "\n\n\t * SONARQUBE is disabled\n"
		fi

	;;
	down|Down|DOWN)
		echo -en "\n\n\t * Stopping (yes|no) : "
		read CONFIRM
		if [ "$CONFIRM" == "yes" ]; then
			echo -e "\n\n\t - confirmed by user\n"
			docker-compose down
			docker-compose -f docker-compose-sonarqube.yml down
			docker-compose -f docker-compose-gitlab.yml down
			cd harbor
			docker-compose down
		else
			echo -e "\n\n\t - canceled by user"
		fi
	;;
	destroy)
		echo -en "\n\n\t - Destroying infra"
		docker-compose down -v --remove-orphans
		docker-compose -f docker-compose-sonarqube.yml down --remove-orphans
		docker-compose -f docker-compose-gitlab.yml down --remove-orphans
		cd harbor; docker-compose down -v
		rm -rf /data/database /data/registry
	;;
	*)
		echo -en "\n\t\t - Unknown parameters : $ACTION\n\n"
	;;
esac
