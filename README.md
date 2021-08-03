This tool provides an easy configuration tool to setup SecuriyOnion 2.3 for
sending event data to a DVM and to GRID.

To install this tool:
- Log into your SecurityOnion server via SSH

NOTE: On a multi-node SO deployment, run this script on the master to deploy and reboot the storage node to take effect immediately (or give it time to pushout)

- use this comand to get the latest copy of this Integraiton:

git clone https://github.com/DefenseStorm/SecurityOnionIntegration.git

Run the script with sudo and provide the DVM IP address and the script will automatically configure
SecurityOnion.

sudo ./setup.sh DVM_IP

The following Files will be added/modified in SecurityOnion:

- /opt/so/saltstack/local/salt/logstash/pipelines/config/custom/DVM.conf
- /opt/so/saltstack/local/pillar/logstash/search.sls

POST SETUP:

Restart logstash:

sudo so-logstash-restart

Check for Errors:

sudo tail -f /opt/so/log/logstash/logstash.log
