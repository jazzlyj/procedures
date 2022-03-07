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
vlan-raw-device enp2s0.200

auto enp2s0.240
iface enp2s0.240 inet static
address 10.240.0.1
netmask 255.255.255.0
vlan-raw-device enp2s0.240

auto enp2s0.32
iface enp2s0.32 inet static
address 10.32.0.1
netmask 255.255.255.0
vlan-raw-device enp2s0.32

```


* bring up the nic

```
sudo ifconfig enp2s0.200 up
```
