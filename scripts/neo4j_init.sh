#!/bin/bash -e
#
# Script for updating initializing NEO4J Support
#################################################

LOGTAG=NEO4J_SUPPORT
NEOHOME="/opt/neo4j"
NEOBIN="/opt/neo4j_support/bin"
NEOETC="/opt/neo4j_support/etc"
NEOBAK="/opt/neo4j/backup"
CONF_FILE=neo4j_support.conf
DIAG_FILE=NEO4J_SUPPORT_DIAGS.sh
SUPPORT_TGZ_FILE=neo4j_support.tar.gz
NEO4j_SERVER_TGZ=neo4jent23.tar.gz


cd /
mkdir -p $NEOETC && chmod 755 $NEOETC
mkdir -p $NEOBIN && chmod 755 $NEOBIN
#
logger -p local0.notice -t $LOGTAG "support directories created"
#
# ensure environment variable set for the neo4j backup directory
#
export NEO4J_BACKUP=$NEOBAK
export PATH=$NEOBIN:$NEOETC:$PATH

# update bash_profile
cat << ENDOC >> ~/.bash_profile
# NEO4J SUPPORT MODIFICATION
if [ -d "/opt/neo4j" ] ; then
	PATH=$PATH:opt/neo4j
fi
if [ -d "/opt/neo4j_support/bin" ] ; then
	PATH=$PATH:/opt/neo4j_support/bin
fi
if [ -d "/opt/neo4j_support/etc" ] ; then
	PATH=$PATH:/opt/neo4j_support/etc
fi
if [ -d "/opt/neo4j/backup" ] ; then
	export NEO4J_BACKUP=/opt/neo4j/backup
fi
set -o noclobber
unset MAILCHECK
EXPORT LANG=C
alias df='df -h'
alias rm='rm -i'
alias h='history | tail'
alias neo='cd /opt/neo4j'
# END NEO4J SUPPORT MODIFICATION
ENDOC

logger -p local0.notice -t $LOGTAG "user $USER profile updated"

# uncompressing neo4j support tarball
tar -zxvf $SUPPORT_TGZ_FILE -C $NEOHOME && logger -p local0.notice -t $LOGTAG "support files deployed"

# moving support files
mv $CONF_FILE $NEOETC
mv $DIAG_FILE $NEOBIN 

# uncompressing neo4j enterprise server
tar -zxvf $NEO4j_SERVER_TGZ $NEOHOME && logger -p local0.notice -t $LOGTAG "Neo4j Enterprise Server files deployed"

AIDETEST=(sudo yum list installed blah |& grep Error | awk '{ print $1 }' | sed s/://) 

if [ $AIDETEST = "Error" ]
then
    echo "AIDE not installed" && logger -p local0.notice -t $LOGTAG "AIDE not installed"
else
    echo "AIDE installed"
fi

# adding group
useradd neo4j -mU -p && logger -p local0.notice -t $LOGTAG "neo4j user created"
echo "create password for neo4j"
echo "Make sure you add neo4j to sudoers file"
#  add: neo4j ALL = (ALL) ALL


 




