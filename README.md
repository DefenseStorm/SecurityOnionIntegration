This tool provides an easy configuration tool to setup SecuriyOnion 2.3 for
sending event data to a DVM and to GRID.

Run the script with sudo and provide the DVM IP address and the script will automatically configure
SecurityOnion.

The following Files will be added/modified in SecurityOnion:

- /opt/so/saltstack/local/salt/logstash/pipelines/config/custom/DVM.conf
- /opt/so/saltstack/local/pillar/logstash/search.sls


