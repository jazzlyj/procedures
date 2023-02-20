# External Routing

## Enable Kernel IP forwarding on Ubuntu Linux Router
Enable IP forwarding in order for the Linux router box for it to function as a router, receive and forward packets.

Once this is done, devices on internal networks should be able to communicate.


* To enable IP forwarding, uncomment the line **net.ipv4.ip_forward=1** in the */etc/sysctl.conf* configuration file.

Check first if the line is already defined on the configuration file;

```bash
grep net.ipv4.ip_forward /etc/sysctl.conf
#net.ipv4.ip_forward=1
```

* if the line is present and commented out, uncomment by running the command below:

```bash
sudo su root
sed -i '/net.ipv4.ip_forward/s/^#//' /etc/sysctl.conf
```

Otherwise, just insert the line;

```bash
sudo su root
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
```

* Apply the changes;

```bash
sudo sysctl -p
```

* Check the status by running the command below;

```bash
sysctl net.ipv4.ip_forward
```

Value should be 1.


* Verify IP forwarding between two private LANs (if two or more are present)


## Configure Packet Forwarding
Configure the packets received from router LAN interfaces *enp2s0* to be forwarded through the WAN interface *wlp1s0*.

```bash
sudo iptables -A FORWARD -i enp2s0 -o wlp1s0 -j ACCEPT
```

* Configure packets that are associated with existing connections received on a WAN interface to be forwarded to the LAN interfaces
```bash
sudo iptables -A FORWARD -i wlp1s0 -o enp2s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

## Configure NATing
```bash
sudo iptables -t nat -A POSTROUTING -o wlp1s0 -j MASQUERADE
```

* If there are more than one local network then ensure the two local networks (example of enp2s0 and enp3s0) can also communicate like so:
```bash
sudo iptables -t nat -A POSTROUTING -o enp2s0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o enp3s0 -j MASQUERADE
```



## Save iptables rules permanently
Install the iptables-persistent package and run the iptables-save command as follows.
```bash
sudo apt install iptables-persistent
```
NOTE: The current rules will be saved during package installation but can still save them thereafter by running the command


# internal routing
NOT NATing. Internal packet forwarding.
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

# bonding and port channels
* setup the bond as 802.3ad
