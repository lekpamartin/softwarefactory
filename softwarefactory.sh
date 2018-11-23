#!/bin/sh

ACTION=$1
WORKINGDIR=`dirname $0`

if [ "$ACTION" == "" ]; then
	echo -en "\n\t $0 up|down\n\n"
	exit 
fi 

HARBOR_RELEASE="1.6.0"
HARBOR_VERSION="1.6.2"

echo -en "\n\t Softwarefactory building \n\n\t Login : " 
read ADMIN_USER
echo -en "\t Password : "
read -s ADMIN_PASSWORD

cd $WORKINGDIR

case $ACTION in
	up|Up|UP)
		echo -en "\n\n\t * Building infra"
		ADMIN_USER=$ADMIN_USER ADMIN_PASSWORD=$ADMIN_PASSWORD docker-compose up -d

		echo -en "\n\n\t * Building Harbor"
		if [ -e harbor ]; then
			echo -en "\n\t\t - Harbor already exist"
		else
			echo -en "\n\t\t - Getting sources (v$HARBOR_VERSION)"
			wget -q https://storage.googleapis.com/harbor-releases/release-$HARBOR_RELEASE/harbor-offline-installer-v$HARBOR_VERSION.tgz
			tar xvf harbor-offline-installer-v$HARBOR_VERSION.tgz
			rm -f harbor-offline-installer-v$HARBOR_VERSION.tgz
		fi
		cd harbor
		./install.sh --with-clair
	;;
	down|Down|DOWN)
		echo -en "\n\n\t - Building infra"
	;;
esac
