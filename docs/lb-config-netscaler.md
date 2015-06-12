
# LoadBalancer configuration of the NetScaler
(see http://support.citrix.com/proddocs/topic/netscaler-traffic-management-10-5-map/ns-lb-setup-wrapper-con.html)


### 1. Enable the `Load Balancing` feature.
```
> enable ns feature LoadBalancing
 Done
```

Let's check, is it's already enabled or not.
```
> show ns feature | grep -i "Load Balancing"
 3)	Load Balancing                 LB                   ON
 10)	Global Server Load Balancing   GSLB                 ON
```


### 2. Creating a Virtual Printing Server
```
> add lb vserver virtual-printserver TCP 10.100.30.222 *
 Done
```
```
> set lb vserver virtual-printserver -lbMethod ROUNDROBIN
 Done
```
```
> show lb vserver virtual-printserver
	virtual-printserver (10.100.30.222:*) - TCP	Type: ADDRESS
	State: DOWN
	Last state change was at Fri Jun 12 07:58:40 2015
	Time since last state change: 0 days, 01:56:18.250
	Effective State: DOWN
	Client Idle Timeout: 9000 sec
	Down state flush: ENABLED
	Disable Primary Vserver On Down : DISABLED
	Appflow logging: ENABLED
	No. of Bound Services :  0 (Total) 	 0 (Active)
	Configured Method: ROUNDROBIN
	Mode: IP
	Persistence: NONE
	Connection Failover: DISABLED
	L2Conn: OFF
	Skip Persistency: None
	IcmpResponse: PASSIVE
	RHIstate: PASSIVE
	New Service Startup Request Rate: 0 PER_SECOND, Increment Interval: 0
	Mac mode Retain Vlan: DISABLED
	DBS_LB: DISABLED
	Process Local: DISABLED
	Traffic Domain: 0
 Done
```


### 3. Creating two Physical Printing Servers

```
> add server printserver-1 10.100.30.231
 Done
> add server printserver-2 10.100.30.232
 Done
```
```
> show server printserver-1
	Name:     printserver-1      State:ENABLED
	IPAddress:   10.100.30.231
 Done
> show server printserver-2
	Name:     printserver-2      State:ENABLED
	IPAddress:   10.100.30.232
 Done
```


### 4. Create two Services for the Physical Print Servers
```
> add service service-printserver-1 printserver-1 TCP *
 Done
> add service service-printserver-2 printserver-2 TCP *
 Done
```
```
> show service service-printserver-1
	service-printserver-1 (10.100.30.231:*) - TCP
	State: DOWN
	Last state change was at Fri Jun 12 08:12:55 2015
	Time since last state change: 0 days, 00:01:07.250
	Server Name: printserver-1
	Server ID : None 	Monitor Threshold : 0
	Max Conn: 0	Max Req: 0	Max Bandwidth: 0 kbits
	Use Source IP: NO
	Client Keepalive(CKA): NO
	Access Down Service: NO
	TCP Buffering(TCPB): NO
	HTTP Compression(CMP): NO
	Idle timeout: Client: 9000 sec	Server: 9000 sec
	Client IP: DISABLED
	Cacheable: NO
	SC: OFF
	SP: OFF
	Down state flush: ENABLED
	Appflow logging: ENABLED
	Process Local: DISABLED
	Traffic Domain: 0

1)	Monitor Name: ping-default
		State: DOWN	Weight: 1	Passive: 0
		Probes: 4	Failed [Total: 4 Current: 4]
		Last response: Failure - No MIP/SNIP available to send the monitor probe.
		Response Time: 2000.0 millisec
 Done
```
```
> show service service-printserver-2
	service-printserver-2 (10.100.30.232:*) - TCP
	State: DOWN
	Last state change was at Fri Jun 12 08:13:03 2015
	Time since last state change: 0 days, 00:01:21.180
	Server Name: printserver-2
	Server ID : None 	Monitor Threshold : 0
	Max Conn: 0	Max Req: 0	Max Bandwidth: 0 kbits
	Use Source IP: NO
	Client Keepalive(CKA): NO
	Access Down Service: NO
	TCP Buffering(TCPB): NO
	HTTP Compression(CMP): NO
	Idle timeout: Client: 9000 sec	Server: 9000 sec
	Client IP: DISABLED
	Cacheable: NO
	SC: OFF
	SP: OFF
	Down state flush: ENABLED
	Appflow logging: ENABLED
	Process Local: DISABLED
	Traffic Domain: 0

1)	Monitor Name: ping-default
		State: DOWN	Weight: 1	Passive: 0
		Probes: 6	Failed [Total: 6 Current: 6]
		Last response: Failure - No MIP/SNIP available to send the monitor probe.
		Response Time: 2000.0 millisec
 Done
```


### 5. Add a Monitor for monitoring the Windows Service "spooler"
```
> add lb monitor monitor-windows-service-spooler HTTP-ECV
 Done
```
```
> show lb monitor monitor-windows-service-spooler
1)   Name.......:monitor-windows-service-spooler  Type......:  HTTP-ECV State....:   ENABLED
Standard parameters:
  Interval.........:            5 sec	Retries...........:                3
  Response timeout.:            2 sec 	Down time.........:           30 sec
  Reverse..........:               NO	Transparent.......:               NO
  Secure...........:               NO	LRTM..............:          ENABLED
  Action...........:   Not applicable	Deviation.........:            0 sec
  Destination IP...:    Bound service
  Destination port.:    Bound service
  Iptunnel.........:               NO
  TOS..............:               NO
  SNMP Alert Retries:               0	  Success Retries..:                1
  Failure Retries..:                0
Special parameters:
  Send string......:
       "GET /"
  Custom headers...:""
  Receive string...:
       ""
 Done
 ```
 ```
> set monitor monitor-windows-service-spooler HTTP-ECV -interval 2 -resptimeout 1 -downTime 5 -destPort 8000 -send "GET /health" -recv "OK"
 Done
> show lb monitor monitor-windows-service-spooler
1)   Name.......:monitor-windows-service-spooler  Type......:  HTTP-ECV State....:   ENABLED
Standard parameters:
  Interval.........:            2 sec	Retries...........:                3
  Response timeout.:            1 sec 	Down time.........:            5 sec
  Reverse..........:               NO	Transparent.......:               NO
  Secure...........:               NO	LRTM..............:          ENABLED
  Action...........:   Not applicable	Deviation.........:            0 sec
  Destination IP...:    Bound service
  Destination port.:             8000
  Iptunnel.........:               NO
  TOS..............:               NO
  SNMP Alert Retries:               0	  Success Retries..:                1
  Failure Retries..:                0
Special parameters:
  Send string......:
       "GET /health"
  Custom headers...:""
  Receive string...:
       "OK"
 Done
 ```


### 6. Binding Monitors to Services
```
> bind lb monitor monitor-windows-service-spooler service-printserver-1
Warning: Argument deprecated [serviceName]
 Done
> bind lb monitor monitor-windows-service-spooler service-printserver-2
Warning: Argument deprecated [serviceName]
 Done
```
```
> show service service-printserver-1
	service-printserver-1 (10.100.30.231:*) - TCP
	State: DOWN
	Last state change was at Fri Jun 12 08:12:55 2015
	Time since last state change: 0 days, 00:16:59.720
	Server Name: printserver-1
	Server ID : None 	Monitor Threshold : 0
	Max Conn: 0	Max Req: 0	Max Bandwidth: 0 kbits
	Use Source IP: NO
	Client Keepalive(CKA): NO
	Access Down Service: NO
	TCP Buffering(TCPB): NO
	HTTP Compression(CMP): NO
	Idle timeout: Client: 9000 sec	Server: 9000 sec
	Client IP: DISABLED
	Cacheable: NO
	SC: OFF
	SP: OFF
	Down state flush: ENABLED
	Appflow logging: ENABLED
	Process Local: DISABLED
	Traffic Domain: 0

1)	Monitor Name: monitor-windows-service-spooler
		State: DOWN	Weight: 1	Passive: 0
		Probes: 28	Failed [Total: 28 Current: 28]
		Last response: Failure - No MIP/SNIP available to send the monitor probe.
		Response Time: 1000.0 millisec
 Done
```
```
> show service service-printserver-2
	service-printserver-2 (10.100.30.232:*) - TCP
	State: DOWN
	Last state change was at Fri Jun 12 08:13:03 2015
	Time since last state change: 0 days, 00:17:22.640
	Server Name: printserver-2
	Server ID : None 	Monitor Threshold : 0
	Max Conn: 0	Max Req: 0	Max Bandwidth: 0 kbits
	Use Source IP: NO
	Client Keepalive(CKA): NO
	Access Down Service: NO
	TCP Buffering(TCPB): NO
	HTTP Compression(CMP): NO
	Idle timeout: Client: 9000 sec	Server: 9000 sec
	Client IP: DISABLED
	Cacheable: NO
	SC: OFF
	SP: OFF
	Down state flush: ENABLED
	Appflow logging: ENABLED
	Process Local: DISABLED
	Traffic Domain: 0

1)	Monitor Name: monitor-windows-service-spooler
		State: DOWN	Weight: 1	Passive: 0
		Probes: 23	Failed [Total: 21 Current: 21]
		Last response: Failure - No MIP/SNIP available to send the monitor probe.
		Response Time: 1000.0 millisec
 Done
```


### 7. Bind Services to Virtual Server
```
> bind lb vserver virtual-printserver service-printserver-1
 Done
> bind lb vserver virtual-printserver service-printserver-2
 Done
```


### Last Step - ATTENTION
At the end, don't forget to save your changes!
```
> save config
 Done
```


DONE.
