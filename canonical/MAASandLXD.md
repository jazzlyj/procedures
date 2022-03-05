# MAAS and LXD 

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

* if you need to drop the db (to start over)
```
sudo -u postgres psql -c "DROP DATABASE maaspgdb"
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


### VLANS and Subnet 
* setup all VLANS
* create and add subnets to VLANs



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





## MAAS and LXD
* setup a node with other disks, like /dev/sdb
* create a partition do NOT format. leave unformatted
* at command line:

``` 
lxc storage create poolzfs zfs source=/dev/sdb2

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

```


* in MAAS webUI change the pool to "disk" from "default"
MAAS - > KVM - > KVM Host Settings - > KVM configuration 
* change "Resource Pool" from default to disk.

Then you will see the other disk/pool created above when on the "Virtual Machines" tab of the UI or the "Resources" tab of the UI



## LXD vm creation


