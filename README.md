# winprint-loadbalancer


## 1. Install and configure the Citrix NetScaler
* [Initially setting up the Citrix NetScaler VPX appliance](https://github.com/DieterReuter/winprint-loadbalancer/blob/master/docs/initial-setup-netscaler.md)
* [LoadBalancer configuration of the NetScaler](https://github.com/DieterReuter/winprint-loadbalancer/blob/master/docs/lb-config-netscaler.md)


## 2. Spin up two Windows Server 2008R2 as Print Servers
```
vagrant up spool-ps1 --no-provision --provider virtualbox
vagrant reload spool-ps1

vagrant up spool-ps2 --no-provision --provider virtualbox
vagrant reload spool-ps2
```


## 3. Check the health state of both Physical Print Servers
```
curl http://10.100.30.231:8000/health
OK
curl http://10.100.30.232:8000/health
OK
```


## 4. Check the health state of the Virtual Print Server
```
curl http://10.100.30.222:8000/health
OK
```


TBC


DONE.