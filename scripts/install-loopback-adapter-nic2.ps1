
$VIP_NAME      = "vip-print"
$VIP_IPADDRESS = "192.168.2.222"
$VIP_IPADDRESS = "10.100.30.222"
$VIP_NETMASK   = "255.255.255.0"
$DEVCON_BINARY   = "C:\vagrant\wintools\devcon.exe"
$NVSPBIND_BINARY = "C:\vagrant\wintools\nvspbind.exe"


#---Create and rename network adapters

# rename the existing NIC to "net"
write-host "Set name of ethernet network adapter to 'net'"
$id = (Get-WmiObject Win32_NetworkAdapter -Filter "Name='Intel(R) PRO/1000 MT Desktop Adapter #2'").NetConnectionID
netsh int set int name = $id newname = "net"

# install loopback adapter, if it doesn't already exists
if ( !(Get-WmiObject Win32_NetworkAdapter -Filter "Description='Microsoft Loopback Adapter'").NetConnectionID ) {
  write-host "Create new loopback adapter"
   Invoke-Expression "$DEVCON_BINARY -r install $env:windir\Inf\Netloop.inf *MSLOOP" | Out-Null
} else {
  write-host "Loopback adapter already exists"
}

# rename the loopback NIC to "loopback"
write-host "Set name of loopback adapter to 'loopback'"
$id = (Get-WmiObject Win32_NetworkAdapter -Filter "Description='Microsoft Loopback Adapter'").NetConnectionID
netsh int set int name = $id newname = "loopback"
  

#---Modify settings on network adapters and registry

# Set the "Register this connection's address in DNS" to unchecked
$nic = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter "Description='Microsoft Loopback Adapter'"
$nic.SetDynamicDNSRegistration($false) | Out-Null

# set static virtual IP address for the cluster IP
$nic.EnableStatic($VIP_IPADDRESS,$VIP_NETMASK) | Out-Null

# disable bindings
# http://archive.msdn.microsoft.com/nvspbind
Invoke-Expression "$NVSPBIND_BINARY /d net ms_tcpip6" | Out-Null
Invoke-Expression "$NVSPBIND_BINARY /d loopback ms_msclient" | Out-Null
Invoke-Expression "$NVSPBIND_BINARY /d loopback ms_pacer" | Out-Null
Invoke-Expression "$NVSPBIND_BINARY /d loopback ms_server" | Out-Null
Invoke-Expression "$NVSPBIND_BINARY /d loopback ms_tcpip6" | Out-Null
Invoke-Expression "$NVSPBIND_BINARY /d loopback ms_lltdio" | Out-Null
Invoke-Expression "$NVSPBIND_BINARY /d loopback ms_rspndr" | Out-Null
# enable bindings
Invoke-Expression "$NVSPBIND_BINARY /e loopback ms_msclient" | Out-Null
Invoke-Expression "$NVSPBIND_BINARY /e loopback ms_server" | Out-Null

# set the binding order
Invoke-Expression "$NVSPBIND_BINARY /++ net *" | Out-Null

# set registry values
New-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Lsa -Name DisableLoopbackCheck -Value '1' -PropertyType DWord -Force | Out-Null
New-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -Name DisableStrictNameChecking -Value '1' -PropertyType DWord -Force | Out-Null
New-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -Name OptionalNames -Value "$VIP_NAME" -PropertyType MultiString -Force | Out-Null

# configure weak host send and weak host receive
netsh interface ipv4 set interface "net" weakhostreceive=enabled | Out-Null
netsh interface ipv4 set interface "loopback" weakhostreceive=enabled | Out-Null
netsh interface ipv4 set interface "loopback" weakhostsend=enabled | Out-Null
