# ubuntu 20

## initial quick setup 
### if not setting up other users - after maas install, login as ubuntu
* ssh as ubuntu from another host
```
ssh ubuntu@$HOST
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


### SSH 
#### setup passwordless ssh
* see [passwordless-ssh](../ssh.md#passwordless-ssh)

* On the desired server, rsync over the authorized_keys file into the target users .ssh dir
```
rsync -av $USERNAME@$IP_ADDR_SERVER:~/.ssh/authorized_keys .
```



## network setup - static ip

* install net-tools
```
sudo apt install net-tools
```

### File (/etc/hosts) name resolution 
* put ips and hostnames in /etc/hosts
```
sudo vi /etc/hosts

# add ip and hostname
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

## setup ssh server
```
sudo apt install openssh-server
sudo systemctl status ssh

# open port on firewall may or may not be needed
sudo ufw allow ssh
```


## packages, update and upgrade
```
apt list --upgradable
```

* update and then upgrade needed packages
```
sudo apt update && sudo apt upgrade
```



## install other useful stuff
```
sudo apt install mlocate
sudo apt install git
sudo apt install vim
sudo apt install python3-pip
sudo apt install python3.10-venv

echo alias shutd=\"sudo /sbin/shutdown\" >> ~/.bash_aliases


```


# Disable swap (for K8s)
* Check if swap is enabled:
```
sudo swapon --show
```

If swap is enabled you will see the path to the swap file and its size.
```
NAME      TYPE      SIZE USED PRIO
/swap.img file        4G   0B   -2
/dev/sda3 partition  32G   0B   -3
```

* You can also check by running the free command:
```
free -h
```

The Swap line shows the total size and how much is used.
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

# remove the line: 
/swap.img      none    swap    sw      0       0
```




# snap package removal
```
sudo snap remove $PACKAGENAMEmaas-test-db --purge

# Eg:
sudo snap remove maas-test-db --purge
```



# Docker setup
https://docs.docker.com/engine/install/linux-postinstall/
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
exit
# log back in
getent group docker
sudo chmod 666 /var/run/docker.sock
```
# install minikube
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
# start with docker driver and give the cluster a static ip address
minikube start --driver docker --static-ip 192.168.200.200
# install kubectl
minikube kubectl -- get pods -A

# if nec install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
kubectl get po -A
```


## dashboard
```bash
# install 
minikube dashboard
minikube addons enable metrics-server

kubectl get pods --namespace=kubernetes-dashboard
kubectl proxy --address 0.0.0.0 kubernetes-dashboard-55c4cbbc7c-n2jcb 8001:80 --namespace=kubernetes-dashboard --disable-filter=true
# go to url from another host- use the IPADDR of the host
http://__IPADDR__:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/#/workloads?namespace=default
```




https://docs.docker.com/engine/install/ubuntu/