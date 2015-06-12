#!/bin/sh

curl -s -i -k -H "Content-Type:application/vnd.com.citrix.netscaler.server+json" -u nsroot:nsroot -X POST -d '{"server":{"name":"test1","ipaddress":"1.2.3.4"}}' "http://$NSIP/nitro/v1/config/server?action=add"
