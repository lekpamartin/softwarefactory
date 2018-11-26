#!/bin/sh

ACTION=$1
WORKINGDIR=`dirname $0`

if [ "$ACTION" == "" ]; then
	echo -en "\n\t $0 up|down\n\n"
	exit 
fi 

HARBOR_RELEASE="1.6.0"
HARBOR_VERSION="1.6.2"
#online|offline
HARBOR_TYPE="online"

echo -en "\n\t Softwarefactory building \n\n\t Login : " 
read ADMIN_USER
echo -en "\t Password : "
read -s ADMIN_PASSWORD

cd $WORKINGDIR

case $ACTION in
	up|Up|UP)
		echo -en "\n\n\t * Running infra\n"
		ADMIN_USER=$ADMIN_USER ADMIN_PASSWORD=$ADMIN_PASSWORD docker-compose up -d

		echo -en "\n\n\t * Harbor"
		if [ -e harbor ]; then
			echo -en "\n\t\t - Harbor already exist"
		else
			echo -en "\n\t\t - Getting sources (v$HARBOR_VERSION)\n"
			wget -q https://storage.googleapis.com/harbor-releases/release-$HARBOR_RELEASE/harbor-$HARBOR_TYPE-installer-v$HARBOR_VERSION.tgz
			tar xvf harbor-$HARBOR_TYPE-installer-v$HARBOR_VERSION.tgz
			rm -f harbor-$HARBOR_TYPE-installer-v$HARBOR_VERSION.tgz
		fi
		cd harbor
		echo -en "\n\t\t - Running \n"
		sed -i "s/ui_url_protocol = http$/ui_url_protocol = https/g" harbor.cfg
		./install.sh --with-clair
	;;
	down|Down|DOWN)
		echo -en "\n\n\t - Building infra"
	;;
	destroy)
		echo -en "\n\n\t - Destroying infra"
		docker-compose down -v
		rm -rf /data/database rm -r /data/registry
	;;
esac
