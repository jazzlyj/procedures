# virtual networking - vlan


```
sudo apt-get install vlan
```


```
modprobe --first-time 8021q
```


```
sudo modprobe --first-time 8021q
```


```
sudo modinfo 8021q
```


* create a vlan
```
sudo ip link add link enp2s0 name enp2s0.200 type vlan id 200
```

* add ip address

```
sudo ip addr add 10.200.0.1/24 dev enp2s0.200
```


* add info to the `/etc/network/interfaces` file
```
auto enp2s0.200
iface enp2s0.200 inet static
address 10.200.0.1
netmask 255.255.255.0
gateway 10.200.0.1
dns-nameservers 10.32.0.10 8.8.8.8 4.4.4.4
vlan-raw-device enp2s0.200

auto enp2s0.32
iface enp2s0.32 inet static
address 10.32.0.1
netmask 255.255.255.0
gateway 10.32.0.1
dns-nameservers 10.32.0.10 8.8.8.8 4.4.4.4
vlan-raw-device enp2s0.32

```


* bring up the nic

```
sudo ifconfig enp2s0.200 up
```


# internal routing
NOT NATing. External packet forwarding.
If the host has multiple networks and is serving as a gateway for those other networks then it needs to be able to forward  

* configure packet forwarding

```
sudo vim /etc/sysctl.conf
# uncomment this line
net.ipv4.ip_forward=1
```

* enable 
```
sudo sysctl -p
```



# bonding and port channels
* setup the bond as 802.3ad
