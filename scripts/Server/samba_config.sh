#!/bin/bash -e
#
#
# Script building Samba shares
###########################################
LOGTAG="NEO4J_SUPPORT"
NEOBASE="/opt/neo4j"
SAMBA_FILE=neoj4_smb.conf
PWDSCRIPT=makesmbpasswd.sh

NEOLOG=neo4j_install.log

if [ -e $NEOLOG]; then
	echo "located log file"
else
	echo "unable to locate log file, creating new log file"
	touch $NEOLOG
fi


cd $NEOBASE
mkdir $NEOBASE/stage && chmod 755 $NEOBASE/stage

firewall-cmd --list-ports | grep 137
if [ $? -ne 0 ]; then
	echo "Samba port 137 not open, aborting script\n"
	logger -p local0.notice -t $LOGTAG "error configuring Samba.  UDP port not open"
	echo "$(date) ERROR: Firewall not configured for Samba"
	exit 1
else
	# continue configuration
	SAMBATEST=$(sudo yum list installed samba |& grep Error | awk '{ print $1 }' | sed s/://) 

	if [ $SAMBATEST== "Error" ]; then
		echo "installing Samba\n"
		
		logger -p local0.notice -t $LOGTAG "installing Samba"
		
		yum install -y samba # samba-client
		
		echo "Samba installed\n"
	
	else
		echo "samba already installed\n"
	fi
	
	mv /etc/samba/smb.conf /etc/samba/smb.conf.bak && cp neo4j_smb.conf /etc/samba/smb.conf
		
	read -p "Enter Windows server name : " winname && sed -i 's/node_name/$winname/' /etc/samba/smb.conf
		
	logger -p local0.notice -t $LOGTAG "updated neo4j Samba configuration"
		
	systemctl enable smb.service
	if [ $? -ne 0 ]; then
		echo "error enabling Samba service\n"
		logger -p local0.notice -t $LOGTAG "error enabling Samba service"
		exit 2
	else
		echo "samba service enabled\n"
		logger -p local0.notice -t $LOGTAG "enabled Samba service"
		systemctl start smb.service
		if [ $? -ne 0 ]; then
			echo "error starting Samba service\n"
			logger -p local0.notice -t $LOGTAG "error starting Samba service"
			exit 3
		else
			echo "started Samba service\n"
			logger -p local0.notice -t $LOGTAG "enabled Samba service"
			
		fi
	fi
	if [ -e $PWDSCRIPT ]; then
		chmod +x $PWDSCRIPT
		cat /etc/passwd | $PWDSCRIPT > /etc/samba/smbpasswd
		chmod 600 /etc/samba/smbpasswd	
	else
		echo "unable to lcoate $PWDSCRIPT"
		echo "$(date) ERROR: unable to locate $PWDSCRIPT, /etc/samba/smbpassword not created" >> $NEOLOG
	fi
fi
