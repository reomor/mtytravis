# reomor_infra
reomor Infra repository
## HW03
connect to private host through bastion via one console command
```
ssh reomor@10.132.0.3 -o "proxycommand ssh -W %h:%p reomor@35.210.242.212"
```
connect to private via alias e.g. ssh someinternalhost
add config to ~/.ssh/config
```
 Host bastion
    User reomor
    Hostname 35.210.242.212

 Host someinternalhost
    User reomor
    Hostname 10.132.0.3
    ProxyCommand ssh -q -W %h:%p bastion
```
install pritunl-client-electron to use cloud-bastion.ovpn
or
openvpn --config cloud-bastion.ovpn
```
bastion_IP = 35.210.242.212
someinternalhost_IP = 10.132.0.3
```
usage of valid certificate in pritunl panel
```
Setting - Lets Encrypt Domain - 35.210.242.212.sslip.io
```
https://35.210.242.212.sslip.io - pritunl panel with valid certificate

## HW04
testapp_IP=104.199.36.51
testapp_port=9292
```
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=startup_script.sh
```
gcloud command to create reddit firewall rule
```
gcloud compute firewall-rules create default-puma-server --allow tcp:9292 \
--target-tags=puma-server --description="Reddit firewall rule added by gcloud compute firewall-rules"
```
