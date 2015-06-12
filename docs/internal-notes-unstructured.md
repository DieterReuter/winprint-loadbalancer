
# winprint-loadbalancer

### Related documents and links
- http://blog.loadbalancer.org/load-balancing-microsoft-print-server/
- https://devcentral.f5.com/questions/ms-print-servers
- http://windowsitpro.com/networking/how-can-i-perform-nslookup-request-against-wins-server
- http://blogs.technet.com/b/heyscriptingguy/archive/2014/01/14/renaming-network-adapters-by-using-powershell.aspx
- https://technet.microsoft.com/en-us/library/jj130867(v=wps.630).aspx
- https://technet.microsoft.com/en-us/magazine/2007.09.cableguy.aspx
- http://www.ehloworld.com/257
- https://support.microsoft.com/en-us/kb/311272
- https://msdn.microsoft.com/en-us/library/windows/hardware/ff544707(v=vs.85).aspx
- http://blog.pcfreak.de/2011/02/17/kommandozeilen-geratemanager-devcon-exe-fur-windows-7/
- WDK7.1 http://download.microsoft.com/download/4/A/2/4A25C7D5-EFBE-4182-B6A9-AE6850409A78/GRMWDK_EN_7600_1.ISO
- https://gallery.technet.microsoft.com/Hyper-V-Network-VSP-Bind-cf937850

- http://blogs.technet.com/b/jhoward/archive/2010/01/25/announcing-nvspbind.aspx
- https://social.technet.microsoft.com/Forums/de-DE/0cad1ba1-8c80-49fe-ad9f-2fff858ced03/setting-ip-addresses-with-win32networkadapterconfiguration?forum=winserverpowershell
- https://4sysops.com/archives/disable-strict-name-checking-with-powershell/
- http://www.tech-no.org/?p=1122




## Short description

This is a testing setup for building a Windows PrintServer Cluster behind a typical Network Loadbalancer like a HAProxy or a Citrix Netscaler.

First of all we just install two identical Windows Server 2008R2 (later on with 2012R2), install the print server role and install some printing queues on these servers.



Downwload the tool `nblookup.exe` from https://support.microsoft.com/de-de/kb/830578 and extract it. Or just use our local binary:
Test the WINS lookup of the virtual server `vip-print` locally on the real print server #1 and #2.
```
\vagrant\wintools\nblookup.exe -s vip-print
```


Renaming the network interfaces
```
C:\vagrant\scripts>netsh interface ipv4 show interface

Idx     Met         MTU          State                Name
---  ----------  ----------  ------------  ---------------------------
  1          50  4294967295  connected     Loopback Pseudo-Interface 1
 11          10        1500  connected     NET
 18          30        1500  connected     LOOPBACK


C:\vagrant\scripts>netsh interface ipv4 show interface

Idx     Met         MTU          State                Name
---  ----------  ----------  ------------  ---------------------------
  1          50  4294967295  connected     Loopback Pseudo-Interface 1
 11          10        1500  connected     NET
 18          30        1500  connected     LOOPBACK


C:\vagrant\scripts>Netsh interface set interface name="NET" newname="NET2"


C:\vagrant\scripts>netsh interface ipv4 show interface

Idx     Met         MTU          State                Name
---  ----------  ----------  ------------  ---------------------------
  1          50  4294967295  connected     Loopback Pseudo-Interface 1
 11          10        1500  connected     NET2
 18          30        1500  connected     LOOPBACK
```


PowerShell: Create Registry items
```
New-ItemProperty HKLM:\System\CurrentControlSet\Control\Lsa -Name "DisableLoopbackCheck" -Value "1" -PropertyType dword
```


Get the `devcon.exe` tool directly from Microsoft:
```
wget http://download.microsoft.com/download/4/A/2/4A25C7D5-EFBE-4182-B6A9-AE6850409A78/GRMWDK_EN_7600_1.ISO
open GRMWDK_EN_7600_1.ISO
cp /Volumes/WDK/WDK/setuptools_x64fre_cab001.cab .
```

Originale Anleitung:
---
Mittlerweile ist “devcon.exe” auch als direkter Download bei Microsoft erhältlich. (Danke an Michael). Den Download gibt es hier.
Um auch an die 64bit Variante zukommen lädt man sich bei Microsoft den Windows Driver Kit Version 7.1.0 als ISO (GRMWDK_EN_7600_1.ISO) herunter und brennt (oder mounted) es.

Auf der CD befindet sich devcon.exe sowohl für ia64, x64 und x86, man muss sie nur finden!

Im Unterordner “WDK” auf der CD befinden sich die Dateien

setuptools_x64fre_cab001.cab
setuptools_x86fre_cab001.cab
setuptools_ia64fre_cab001.cab

für die entsprechende Plattform (x64, x86 oder ia64). Diese CAB-Datei kann man mit handelsüblichen Programmen entpacken. Darin enthalten ist dann jeweils die Datei

_devcon.exe_00000

Diese muss man umbenennen in

devcon.exe
---
wget https://gallery.technet.microsoft.com/Hyper-V-Network-VSP-Bind-cf937850/file/117120/1/Microsoft_Nvspbind_package.EXE


List all available network adapters:
```
get-wmiobject win32_networkadapter -filter "netconnectionstatus = 2" 

```

VMware Fusion Network settings
http://sanbarrow.com/vmx/vmx-network-advanced.html
ls -al /Library/Preferences/VMware\ Fusion/

vboxnet6: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	ether 0a:00:27:00:00:06
	inet 10.10.51.1 netmask 0xffffff00 broadcast 10.10.51.255

File=~/Documents/Virtual Machines.localized/NSVPX-ESX-10.5-55.8_nc.vmwarevm/NSVPX-ESX-10.5-55.8_nc.vmx

...change...
ethernet0.connectionType = "bridged"
ethernet1.connectionType = "bridged"
...to...
ethernet0.connectionType = "custom"
ethernet0.vnet = "vboxnet6"
ethernet1.connectionType = "custom"
ethernet1.vnet = "vboxnet6"
...

Remove Network interface
```
VBoxManage hostonlyif remove vboxnet6
```


NetScaler via NITRO API
http://blogs.citrix.com/2014/02/04/using-curl-with-the-netscaler-nitro-rest-api/
```
curl -u nsroot:nsroot http://192.168.2.200/nitro/v1/stat
curl -u nsroot:nsroot http://192.168.2.200/nitro/v1/config
```


