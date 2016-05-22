README.txt
Written By Christopher Upkes
######################################
To begin neo4j server installation, ensure that you are logged in as the neo4j user.

Then make sure you are in the neo4j home directory:

cd ~

pwd should show /home/neo4j

now edit the cluster.conf file.

Add the hostnames and ip addresses of each nodes as provided by the example in the cluster.conf file.

The select where you want to initalize the host by installing jdk, auditing, firewall config, etc...

When complete, make sure you save the file.

next, execute:

chmod +x neo4j_init.sh

This sets the executable bit on the file.

next, execute the neo4j master initialzation script as super user:

sudo ./neo4j_init.sh

the script will send report to he console but will also save log entries to:

/var/log/messages

and the neo4j_install.log file in the /home/neo4j directory.


