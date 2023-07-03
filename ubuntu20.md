# ubuntu 20

## initial quick setup 
### after maas install, login as ubuntu 
* ssh as ubuntu from another host
```
ssh ubuntu@node1
```

### create user and to sudo group
* create the user
```
sudo adduser $USERNAME
```

* add user to sudo group
```
sudo usermod -aG sudo $USERNAME
```
NOTE: The "a" is very important. Without it they'll be removed from all other groups. 
You will need to either restart your shell/terminal or log out and back in for this to take effect.

### copy over ssh keys
* rsync the .ssh dir of the $USERNAME from a server ($IP_ADDR_SERVER) which the user is on.
```
rsync -av $USERNAME@$IP_ADDR_SERVER:~/.ssh .
```


### setup passwordless ssh
* see [adding-public-key-to-authorized_keys](ssh.md#adding-public-key-to-authorized_keys)



## network setup - static ip

* install net-tools
```
sudo apt install net-tools
```

* put ip and others in /etc/hosts
```
sudo vi /etc/hosts

# add ip and hostnameR
ipv4 hostname
```

* override cloud-init's net config
```
sudo vi /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

# add:
network: {config:disable}
```

* create and edit a netplan file 
NOTE: change 
  * adapter (eg: enp0s2, eth0)
  * ipaddr/CIDR 
  * search domains

```
sudo vi /etc/netplan/99_config.yaml
```
* add this content:
```
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s2:
      addresses:
        - 192.168.0.100/24
      gateway4: 192.168.0.1
      nameservers:
          search: [mydomain, otherdomain]
          addresses: [1.1.1.1, 8.8.8.8, 4.4.4.4]

```

* restart networking
```
sudo netplan apply
```

## setup ssh
```
sudo apt install openssh-server
sudo systemctl status ssh

# open port on firewall may or may not be needed
sudo ufw allow ssh
```




## list updates needed and do updates
```
apt list --upgradable
```

* update app and then upgrade needed packages
```
sudo apt update && sudo apt upgrade
```


## generate ssh keys and add to ssh agent 

```
mkdir .ssh; cd .ssh

ssh-keygen -t ed25519 -C "your_email@example.com"
# or 
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

## install other useful stuff
```
sudo apt install mlocate
sudo apt install git
sudo apt install vim
sudo apt install python3-pip

```


# Disable swap
https://graspingtech.com/disable-swap-ubuntu/#:~:text=How%20to%20Disable%20Swap%20on%20Ubuntu%20Linux%2020.04,check%20Swap%20is%20disabled.%20...%204%20Conclusion.%20

* Check if swap is enabled:
```
sudo swapon --show
```
If swap is enabled you should see the path to the swap file and its size.

```
NAME      TYPE      SIZE USED PRIO
/swap.img file        4G   0B   -2
/dev/sda3 partition  32G   0B   -3
```

* You can also check by running the free command:
```
free -h
```
The Swap line should show the total size and how much is used.

```
free -h
              total        used        free      shared  buff/cache   available
Mem:           15Gi       4.5Gi       8.2Gi        22Mi       2.8Gi        10Gi
Swap:          35Gi          0B        35Gi
```

* Remove swap
```
sudo swapoff -a
sudo rm /swap.img
sudo vi /etc/fstab
```
  * remove the line: <br>
  /swap.img      none    swap    sw      0       0





# snap package management
```
sudo snap remove maas-test-db --purge
```







































```
microk8s.kubectl get nodes

Insufficient permissions to access MicroK8s.
You can either try again with sudo or add the user jay to the 'microk8s' group:
   sudo usermod -a -G microk8s jay
   sudo chown -f -R jay ~/.kube
 After this, reload the user groups either via a reboot or by running 'newgrp microk8s'.
```



























## Make ISO image
### Pre-reqs
```
sudo apt install p7zip-full
sudo apt-get install cloud-init
```






## DNSMASQ
```
apt install dnsmasq
```

When you start dnsmasq, if it complains about port 53 alreay in use

dnsmasq: failed to create listening socket for port 53: Address already in use

* stop systemd-resolved. 

```
systemctl disable systemd-resolved
# mask it so it does not startup on boot
sudo systemctl mask systemd-resolved
systemctl stop systemd-resolved
```

* start dnsmasq

```
systemctl start dnsmasq
```

* enable DNS caching/resolver, you need to edit file
```
vi /etc/dnsmasq.conf
# Add line

server=8.8.8.8
server=1.1.1.1
```

* Restart dnsmasq
```
systemctl restart dnsmasq
```








installed with: docker, promethius, juju




# Build autoinstall iso and set it up for netbooting 
* build autoinstall iso imag with custom user-data
```
~/iso/ubuntu-autoinstall-generator$ ./ubuntu-autoinstall-generator.sh -u ../user-data
```
reference:
https://github.com/covertsh/ubuntu-autoinstall-generator


* 

