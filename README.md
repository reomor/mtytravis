# reomor_infra
reomor Infra repository

## HW03
### description
different variants to connect host through basion host

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
### description
create VM instance with deployed application (puma-server) via gcloud

```
testapp_IP=104.199.36.51
testapp_port=9292
```
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

## HW05
### description
building VM image with embedded application (puma-server) and VM instance with packer and gcloud
add credentials
```
gcloud auth application-default login
```
useful commands
```
packer validate ./ubuntu16.json
packer build ubuntu16.json
packer build -var-file variables.json ubuntu16.json 
```
## HW06
### description
useful commands
```
terraform init
terraform plan
terraform apply -auto-approve=true
terrafrom show
terraform refresh
terraform output
terraform output app_external_ip
terraform taint google_compute_instance.app
terraform destroy
terraform fmt
```
#### Optional*
add ssh key to project metadata
```
resource "google_compute_project_metadata" "ssh_keys" {
  project = "${var.project}"
  metadata {
    ssh-keys = "appuser1:${file(var.public_key_path)}"
  }
}
```
or
```
resource "google_compute_project_metadata_item" "appuser1" {
  key = "ssh-keys"
  value = "appuser1:${file(var.public_key_path)}"
}

```
add ssh keys to project metadata
```
resource "google_compute_project_metadata" "ssh_keys" {
  project = "${var.project}"
  metadata {
    ssh-keys = "appuser1:${file(var.public_key_path)}\nappuser2:${file(var.public_key_path)}"
  }
}
```
after add new ssh key through GCP web-interface
```
terraform apply
```
deletes all existing ssh-key and inserts only keys in template main.tf
#### Optional**
the problem of such configuration is:
 - each instance needs manual add in cluster
 - each instance has external ip
 - lb starts delay too much

## HW07

[![Build Status](https://api.travis-ci.com/Otus-DevOps-2018-09/reomor_infra.svg?branch=terraform-2)](https://github.com/Otus-DevOps-2018-09/reomor_infra/tree/terraform-2)

### description
using terraform modules and backend to store terraform state in GCP

if terraform controls yout firewall rules - do NOT forget to add default-ssh-allow after 
```
terraform destroy
gcloud compute firewall-rules create default-allow-ssh --allow tcp:22
```
so that parker could get ssh access to VM
import rule to terraform state
```
terraform import google_compute_firewall.firewall_ssh default-allow-ssh
terraform get
```
list of all buckets
```
gsutil ls
```
---
Optional *
if stage and prod have common bucket:
```
provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

resource "google_storage_bucket" "state_bucket" {
  name = "terraform-state-storage-bucket"

  versioning {
    enabled = true
  }

  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_acl" "state_storage_bucket_acl" {
  bucket         = "${google_storage_bucket.state_bucket.name}"
  predefined_acl = "private"
}
```
and the same backend without prefix
```
terraform {
  backend "gcs" {
    bucket = "terraform-state-storage-bucket"
  }
}
```
apply at the same time in stage and prod gives lock:
```
terraform apply
Terraform acquires a state lock to protect the state from being written...
```
but both see the same state
---
Optional **
add provisioner to transfer db server ip address
```
connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "${path.module}/files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "file" {
    source      = "${path.module}/files/deploy.sh"
    destination = "/tmp/deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/deploy.sh",
      "/tmp/deploy.sh ${var.db_internal_ip}"
    ]
  }
```
difference from base deploy.sh is
```
...
sudo mv /tmp/puma.service /etc/systemd/system/puma.service
sudo sed -i "s/Environment=/Environment=DATABASE_URL=$DATABASE_URL/" /etc/systemd/system/puma.service
sudo systemctl start puma
...
```
add provisioner to allow mongod access not only from localhost
```
connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "${path.module}/files/bind.sh"
    destination = "/tmp/bind.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bind.sh",
      "/tmp/bind.sh"
    ]
  }
```
content of bind.sh is
```
sudo sed -i "s/bindIp: 127.0.0.1/bindIp: 0.0.0.0/" /etc/mongod.conf
sudo service mongod restart
```
