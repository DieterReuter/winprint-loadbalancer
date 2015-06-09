
$VIP_NAME      = "vip-print2"
$VIP_IPADDRESS = "10.0.2.200"
$VIP_NETMASK   = "255.255.255.0"

#---

# rename the existing NIC to "net"
$id = (Get-WmiObject Win32_NetworkAdapter -Filter "Name='Intel(R) PRO/1000 MT Desktop Adapter'").NetConnectionID
netsh int set int name = $id newname = "net"

# install loopback adapter
\vagrant\wintools\devcon.exe -r install $env:windir\Inf\Netloop.inf *MSLOOP | Out-Null

# rename the loopback NIC to "loopback"
$id = (Get-WmiObject Win32_NetworkAdapter -Filter "Description='Microsoft Loopback Adapter'").NetConnectionID
netsh int set int name = $id newname = "loopback"
  
#---

# Set the "Register this connection's address in DNS" to unchecked
$nic = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter "Description='Microsoft Loopback Adapter'"
$nic.SetDynamicDNSRegistration($false) | Out-Null

# set static virtual IP address for the cluster IP
$nic.EnableStatic($VIP_IPADDRESS,$VIP_NETMASK) | Out-Null

# disable bindings
# http://archive.msdn.microsoft.com/nvspbind
\vagrant\wintools\nvspbind /d "net" ms_tcpip6 | Out-Null
\vagrant\wintools\nvspbind /d "loopback" ms_msclient | Out-Null
\vagrant\wintools\nvspbind /d "loopback" ms_pacer | Out-Null
\vagrant\wintools\nvspbind /d "loopback" ms_server | Out-Null
\vagrant\wintools\nvspbind /d "loopback" ms_tcpip6 | Out-Null
\vagrant\wintools\nvspbind /d "loopback" ms_lltdio | Out-Null
\vagrant\wintools\nvspbind /d "loopback" ms_rspndr | Out-Null
# enable bindings
\vagrant\wintools\nvspbind /e "loopback" ms_msclient | Out-Null
\vagrant\wintools\nvspbind /e "loopback" ms_server | Out-Null

# set the binding order
\vagrant\wintools\nvspbind /++ "net" * | Out-Null

# set registry values
New-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa -Name DisableLoopbackCheck -Value '1' -PropertyType DWord -Force | Out-Null
New-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -Name DisableStrictNameChecking -Value '1' -PropertyType DWord -Force | Out-Null
New-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -Name OptionalNames -Value "$VIP_NAME" -PropertyType MultiString -Force | Out-Null

# configure weak host send and weak host receive
netsh interface ipv4 set interface "net" weakhostreceive=enabled | Out-Null
netsh interface ipv4 set interface "loopback" weakhostreceive=enabled | Out-Null
netsh interface ipv4 set interface "loopback" weakhostsend=enabled | Out-Null
