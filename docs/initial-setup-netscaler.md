
# Initially setting up the Citrix NetScaler VPX appliance

For the first time you install a new NetScaler appliance you have to configure a few basic things to get this thing up and running:
* install NetScaler as a VMware VM
* TIP: setting a dedicated MAC address to it's first NIC (this MAC address will be used for the license)
* boot the VM
* login to the console (default credentials user=nsroot, password=nsroot)
* setting the IP address, network mask
* reboot the VM and you're done
* install license file
* reboot to activate license


## Configuring the NetScaler IP Address (NSIP)
(see http://support.citrix.com/proddocs/topic/ns-system-10-map/ns-nw-ipaddrssng-confrng-nsip-tsk.html)

Let's assume, we'd like to have the following parameters
* `NSIP=10.100.30.200`
* `MSMASK=255.255.255.0`
* `SNIP=10.100.30.220`


To change the NetScaler IP address you have to login to the console. For a VMware VM that's available throught the VMware console view of the VM. When logged in, you have the NetScaler CLI which isn't the OS shell! If you like, you can also using the command `shell` to get to the OS shell prompt.

Get the current network settings
```
> show ns config
	NetScaler IP: 10.100.30.240  (mask: 255.255.255.0)
	 NW FWMODE: NOFIREWALL
	Number of MappedIP(s): 0
	Node: Standalone
	                   System Time: Fri Jun 12 07:29:26 2015
	      Last Config Changed Time: Fri Jun 12 07:19:02 2015
	        Last Config Saved Time: Fri Jun 12 07:16:11 2015
 Done
```

Now, let's change the IP address to `10.100.30.200`
```
> set ns config -ipaddress 10.100.30.200 -netmask 255.255.255.0
Warning: The configuration must be saved and the system rebooted for these settings to take effect
```

```
> show ns config
	NetScaler IP: 10.100.30.200  (mask: 255.255.255.0)
	 NW FWMODE: NOFIREWALL
	Number of MappedIP(s): 0
	Node: Standalone
	                   System Time: Fri Jun 12 07:29:52 2015
	      Last Config Changed Time: Fri Jun 12 07:29:48 2015
	        Last Config Saved Time: Fri Jun 12 07:16:11 2015
WARNING: The configuration must be saved and the system rebooted for these settings to take effect
 Done
```

For the communication with the backend servers, we have to define a Subnet IP Address (SNIP).
```
> add ns ip 10.100.30.220 255.255.255.0 -type SNIP
 Done
```
```
> show ns ip
  	Ipaddress        Traffic Domain  Type             Mode     Arp      Icmp     Vserver  State
  	---------        --------------  ----             ----     ---      ----     -------  ------
1)	10.100.30.200    0               NetScaler IP     Active   Enabled  Enabled  NA       Enabled
2)	10.100.30.222    0               VIP              Active   Enabled  Enabled  Enabled  Enabled
3)	10.100.30.220    0               SNIP             Active   Enabled  Enabled  NA       Enabled
 Done
```

Once this is done, you have to save the new configuration
```
> save ns config
 Done
```

And now reboot the appliance. But here you have to confirm the reboot by manually typing a 'Y'
```
> reboot
Are you sure you want to restart NetScaler (Y/N)? [N]:
```
Or just use the force mode without any further user interaction
```
> reboot -f
```
A reboot will take a minute or two, so just please be patient.

From now on, we can leave the VMware console view and login to the NetScaler appliance via `ssh` from Linux or OSX or using `PuTTy` from Windows.
```
# ping 10.100.30.200
PING 10.100.30.200 (10.100.30.200): 56 data bytes
64 bytes from 10.100.30.200: icmp_seq=0 ttl=64 time=0.782 ms
64 bytes from 10.100.30.200: icmp_seq=1 ttl=64 time=1.048 ms
64 bytes from 10.100.30.200: icmp_seq=2 ttl=64 time=0.819 ms
64 bytes from 10.100.30.200: icmp_seq=3 ttl=64 time=1.003 ms
```

```
# ssh-keygen -R 10.100.30.200
# ssh nsroot@10.100.30.200
The authenticity of host '10.100.30.200 (10.100.30.200)' can't be established.
RSA key fingerprint is 78:40:30:b9:c3:b0:75:fd:11:0e:82:bf:77:bb:dd:51.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.100.30.200' (RSA) to the list of known hosts.
Password:
Last login: Fri Jun 12 07:29:14 2015 from 10.100.30.5
 Done
>
```


### Installing NetScaler Licenses
(see: http://support.citrix.com/proddocs/topic/netscaler-migration-10/ns-instpk-inst-ns-licns-tsk.html)

Install the license file via `scp` from OSX
```
# scp ./FID__5ecff173_14dbb436215__4bcf.lic nsroot@10.100.30.200:/nsconfig/license/
Password:
FID__5ecff173_14dbb436215__4bcf.lic                                                                  100% 2201     2.2KB/s   00:00
```

Reboot the NetScaler to activate the license
```
ssh nsroot@10.100.30.200 reboot -w
```


Success, now you have set up the NetScaler appliance.
