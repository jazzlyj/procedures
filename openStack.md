https://docs.openstack.org/project-deploy-guide/charm-deployment-guide/latest/install-overview.html

# multi-node OpenStack cloud with MAAS, Juju, and OpenStack Charms

The purpose of the Installation section is to demonstrate how to build a multi-node OpenStack cloud with MAAS, Juju, and OpenStack Charms. 
For easy adoption the cloud will be minimal. 
Nevertheless, it will be capable of both performing some real work and scaling to fit more ambitious projects. 
High availability will not be implemented beyond natively HA applications (Ceph, MySQL, OVN, Swift, and RabbitMQ).

The software versions used in this guide are as follows:

* Ubuntu 20.04 LTS (Focal) for the MAAS server, Juju client, Juju controller, and all cloud nodes (including containers)
* MAAS 3.0.0
* Juju 2.9.15



## pre-reqs
* update apt 
```
sudo apt update -y
```



* install needed dependencies
```
sudo apt install make jq
sudo apt install -y postgresql

```



## MAAS install including Postgres DB
```
sudo snap install --channel=3.0/stable maas

sudo -u postgres psql -c "CREATE USER \"$MAAS_DBUSER\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"
sudo -u postgres psql -c "CREATE USER \"maaspguser\" WITH ENCRYPTED PASSWORD '$MAAS_DBPASS'"

sudo -u postgres createdb -O "$MAAS_DBUSER" "$MAAS_DBNAME"
sudo -u postgres createdb -O "maaspguser" "maaspgdb"

sudo vi /etc/postgresql/12/main/pg_hba.conf
# add a line
host    $MAAS_DBNAME            $MAAS_DBUSER      0/0                     md5

# Eg:
# host    maaspgdb        maaspguser      0/0                     md5

# NOTE: for db running on same host as maas use localhost
sudo maas init region+rack --database-uri "postgres://$MAAS_DBUSER:$MAAS_DBPASS@$HOSTNAME/$MAAS_DBNAME"
sudo maas init region+rack --database-uri "postgres://maaspguser:$MAAS_DBPASS@localhost/maaspgdb"

```


* create an admin
```
sudo maas createadmin --username <username> --password <password> --email <username>@<hostname> 
```

* create api key
eg:
```
sudo maas apikey --username=maasadmin > ~/maasadmin-api-key
```

* login
```
maas login maasadmin http://$IPADDR:5240/MAAS - < ~/maasadmin-api-key
```
NOTE: you will need to put in the api key again even though you redirected its input

### Set DNS
```
maas maasadmin  maas set-config name=upstream_dns value="8.8.8.8"
```


### DHCP
* see [maasDHCP.png](maasDHCP.png)



### Set metal nodes to PXE boot (outside of MAAS)



### Node Life Cycle in MAAS in UI
* Make sure to press the buttons for the Action then power on the node and it then does the action
     * Actions are: Commission, Acquire, Deploy, 


### Deploy, with user-data 
* When "Deploy"ing a node inside maas check cloud-init and paste the following lines:
``` 
#cloud-config
system_info:
  default_user:
    name: $NAME
    gecos: $FULL_NAME
    homedir: /home/$NAME
    primary_group: $NAME
    lock_passwd: false
    groups: [adm, sudo]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
```



### MAAS imaged/managed node details
* initial login. From another host

```
ssh ubuntu@node1
```



## MAAS and LXD
* setup a node with other disks like /dev/sdb
* create a partition do NOT format. leave unformatted
* at command line:

``` 
lxc storage create poolzfs zfs source=/dev/sdb2
# if using the whole disk use "sdb" instead of sdb2

```


Eg:
```
lxc storage list
+---------+--------+------------------------------------------------+-------------+---------+
|  NAME   | DRIVER |                     SOURCE                     | DESCRIPTION | USED BY |
+---------+--------+------------------------------------------------+-------------+---------+
| default | dir    | /var/snap/lxd/common/lxd/storage-pools/default |             | 1       |
+---------+--------+------------------------------------------------+-------------+---------+


lxc storage create poolzfs zfs source=/dev/sdb2
Storage pool poolzfs created


lxc storage list
+---------+--------+------------------------------------------------+-------------+---------+
|  NAME   | DRIVER |                     SOURCE                     | DESCRIPTION | USED BY |
+---------+--------+------------------------------------------------+-------------+---------+
| default | dir    | /var/snap/lxd/common/lxd/storage-pools/default |             | 1       |
+---------+--------+------------------------------------------------+-------------+---------+
| poolzfs | zfs    | poolzfs                                        |             | 0       |
+---------+--------+--------------------




* in MAAS webUI change the pool to "disk" from "default"
MAAS - > KVM - > KVM Host Settings - > KVM configuration 
* change "Resource Pool" from default to disk.

Then you will see the other disk/pool created above when on the "Virtual Machines" tab of the UI or the "Resources" tab of the UI



## LXD vm creation











## Openstack Install and Setup



*
```

```





*
```

```


*
```

```





































## MAAS details
### MAAS file locations
* images are stored here:
```
/var/snap/maas/common/maas/boot-resources/current/
```

* pre-seeds stored here:
```
/var/snap/maas/current/preseeds
```




## LXD install

* preseed yaml
```
config:
  core.https_address: '[::]:8443'
  core.trust_password: $PASSWORD
networks: []
storage_pools:
- config: {}
  description: ""
  name: default
  driver: dir
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: mpqemubr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
projects: []
cluster: null
```













### Creating a custom image
* install packer
https://learn.hashicorp.com/tutorials/packer/get-started-install-cli
```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer
```

* install other needed packages
```
sudo apt install qemu-utils ovmf cloud-image-utils

```


* get packer ubuntu source code and customize the user-data file
```
cd /path/to/work
git clone 

```



* create image 
```

```





### add a custom image to MAAS
* move the generated image to /home or /media
NOTE: as of maas 3.1, it can only see these dirs
```
cp /tmp/focal-custom.tgz /home/$USER
```


* first login, see above



* then add boot-resource
```
maas maasadmin boot-resources create name='custom/ubuntu-custom' architecture=amd64/generic title=’custom ubuntu’ base_image=ubuntu/focal
 filetype=ddraw content@=./ubuntu-autoinstall-2021-12-30.
```





*
```

```

*
```

```

*
```

```



## MAAS install from source 
* Get MAAS source files
```
git clone --recurse-submodules https://git.launchpad.net/maas maas-rpi
cd maas-rpi
```

* Patch MAAS to do what it needs for Pi
```
vi maas-rpi.patch

# add this content to the file and wq:

diff --git a/src/provisioningserver/dhcp/config.py b/src/provisioningserver/dhcp/config.py
index 717c6e4..f3f8c4d 100644
--- a/src/provisioningserver/dhcp/config.py
+++ b/src/provisioningserver/dhcp/config.py
@@ -27,7 +27,7 @@
 
 logger = logging.getLogger(__name__)
 
-
+    
 # Used to generate the conditional bootloader behaviour
 CONDITIONAL_BOOTLOADER = tempita.Template(
     """
@@ -102,6 +102,11 @@
     {{if http_client}}
     option vendor-class-identifier "HTTPClient";
     {{endif}}
+    option vendor-class-identifier \"PXEClient\";
+        vendor-option-space PXE;
+            option PXE.discovery-control 3;
+            option PXE.boot-menu 0 17 \"Raspberry Pi Boot\";
+            option PXE.menu-prompt 0 \"PXE\";
 }
 {{endif}}
 {{endif}}
@@ -136,6 +141,11 @@
             option dhcp-parameter-request-list,d2);
     }
     {{endif}}
+    option vendor-class-identifier \"PXEClient\";
+        vendor-option-space PXE;
+            option PXE.discovery-control 3;
+            option PXE.menu-prompt 0 \"PXE\";
+            option PXE.boot-menu 0 17 \"Raspberry Pi Boot\";
 }
 {{endif}}
 """

```
* apply the patch to maas
```
patch -p1 < maas-rpi.patch
```

* make maas
```
make install-dependencies
make snap
```

```
export SETUPTOOLS_USE_DISTUTILS=stdlib
```

3.2.0~alpha1-11011-g.4f1fadaa6


### Open the firewall - not sure if needed
```
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
sudo ufw allow 67/udp
sudo ufw allow 69/udp
sudo ufw allow 4011/udp
```
