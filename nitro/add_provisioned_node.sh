#!/bin/sh

# This script takes 5 arguments and uses cURL to call the NetScaler Nitro API to add a newly provisioned
# server node to an existing service group on the specified NetScaler appliance or instance. For NetScalers
# configured in HA pairs, a SNIP with management should be enabled should be used as that will represent
# the active node.  The cURL can be executed in the context of the nsroot account but a specific account with 
# a bound command authorization policy can be used to restrict access - i.e.:
#
# add system user automation 100a26e3cfb59d27cf1c05a1f6d88575c1d565aa6371c393a -encrypted -externalAuth DISABLED -timeout 60
# add system cmdPolicy automation_allow_policy ALLOW "(^save\\s+ns\\s+config)|(^save\\s+ns\\s+config\\s+.*)|(^add\\s+server)|(^add\\s+server\\s+.*)|(^bind\\s+serviceGroup)|(^bind\\s+serviceGroup\\s+.*)"
# bind system user automation automation_allow_policy 100

# root@lab# ./add_provisioned_node.sh "test1" "1.2.3.4" "80" "test_server_group" "10.233.50.12"


# Set Variables
node_name=$1         #test1
node_ip=$2           #1.2.3.4
node_listener=$3     #80
servicegroup_name=$4 #test_server_group
nsip=$5              #10.233.50.12

# Add a New Server Node
params="-s -i -k -H Content-Type:application/vnd.com.citrix.netscaler.server+json --basic --user automation:password  -X POST -d {\"server\":{\"name\":\"${node_name}\",\"ipaddress\":\"${node_ip}\"}} https://${nsip}/nitro/v1/config/server?action=add"
content="$(curl $params | grep HTTP/1.0 | tail -1 | awk {'print $2'})"
if [ "$content" = 201 ]; then
	# Bind the Server to an Existing Service Group
	params="-s -i -k -H Content-Type:application/vnd.com.citrix.netscaler.servicegroup_servicegroupmember_binding+json --basic --user automation:password  -X PUT -d {\"servicegroup_servicegroupmember_binding\":{\"servicegroupname\":\"${servicegroup_name}\",\"servername\":\"${node_name}\",\"port\":\"${node_listener}\"}}  https://${nsip}/nitro/v1/config/servicegroup_servicegroupmember_binding/${servicegroup_name}?action=bind"
	content="$(curl $params | grep HTTP/1.0 | tail -1 | awk {'print $2'})"
	if [ "$content" = 200 ]; then
		# Save the Configuration
		params="-s -i -k -H Content-Type:application/vnd.com.citrix.netscaler.nsconfig+json --basic --user automation:password  -X POST -d {\"nsconfig\":{}}  https://${nsip}/nitro/v1/config/nsconfig?action=save"
		content="$(curl $params | grep HTTP/1.0 | tail -1 | awk {'print $2'})"
		if [ "$content" != 200 ]; then		
			echo "error saving config:" $content
			exit 1
		fi
	else
		echo "error binding new node:" $content
		exit 1
	fi
else
	echo "error creating server node:" $content
	exit 1
fi
echo "successfully added node" $node_name "to" $servicegroup_name 
exit 0 # Exit With Success