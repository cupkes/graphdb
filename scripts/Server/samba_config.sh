#!/bin/bash -e
#
#
# Script building Samba shares
###########################################
LOGTAG="NEO4J_SUPPORT"
NEOBASE="/opt/neo4j"
SAMBA_FILE=neoj4_smb.conf

cd $NEOBASE
mkdir $NEOBASE/stage && chmod 755 $NEOBASE/stage

firewall-cmd --list-ports | grep 137
if [ $? -eq 0 ]; then
	echo "Samba port 137 not open, aborting script\n"
	logger -p local0.notice -t $LOGTAG "error configuring Samba.  UDP port not open"
	exit 1
else
	# continue configuration
	SAMBATEST=(sudo yum list installed samba |& grep Error | awk '{ print $1 }' | sed s/://) 

	if [ $AIDETEST = "Error" ]; then
		echo "installing Samba\n"
		logger -p local0.notice -t $LOGTAG "installing Samba"
		yum install -y samba # samba-client
		echo "Samba installed\n"
		mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
		cp neo4j_smb.conf /etc/samba/smb.conf
		logger -p local0.notice -t $LOGTAG "copied neo4j Samba configuration"
	else
		echo "samba already installed\n"
	fi
	read -p "Enter node host name : " nodename
	
	cat /etc/hosts | grep $nodename
	if [ $? -eq 0 ]; then
		echo "node name not found in hosts file\n"
		echo "please replace netbios name in smb.conf with valid host name\n"
	else
		sed -i s/node_name/$nodename /etc/samba/smb.conf
		echo "updated smb.conf with netbios name = $nodename\n"
		logger -p local0.notice -t $LOGTAG "updated Samba configuration"
	systemctl enable smb.service
	if [ $? -eq 0 ]; then
		echo "error enabling Samba service\n"
		logger -p local0.notice -t $LOGTAG "error enabling Samba service"
		exit 2
	else
		echo "samba service enabled\n"
		logger -p local0.notice -t $LOGTAG "enabled Samba service"
		systemctl start smb.service
		if [ $? -eq 0 ]; then
			echo "error starting Samba service\n"
			logger -p local0.notice -t $LOGTAG "error starting Samba service"
			exit 3
		else
			echo "started Samba service\n"
			logger -p local0.notice -t $LOGTAG "enabled Samba service"
			
		fi
	fi
	chmod +x $NEOBASE/etc/makesmbpasswd.sh
	cat /etc/passwd | mksmbpasswd.sh > /etc/samba/smbpasswd
	chmod 600 /etc/samba/smbpasswd	
fi
