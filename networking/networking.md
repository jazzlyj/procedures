# Network management


## [Networkd and Netplan](https://ubuntu.com/core/docs/networkmanager)
By default network management on Ubuntu Core is handled by systemd’s [networkd](https://www.freedesktop.org/software/systemd/man/systemd-networkd.service.html) and [netplan](https://launchpad.net/netplan). However, when NetworkManager is installed, it will take control of all networking devices in the system by creating a netplan configuration file in which it sets itself as the default network renderer.

* YAML network configuration abstraction for various backends (NetworkManager, networkd)

netplan reads network configuration from /etc/netplan/*.yaml which are written by administrators, installers, cloud image instantiations, or other OS deployments. During early boot it then generates backend specific configuration files in /run to hand off control of devices to a particular networking daemon.


## NetworkManager
All the connection configuration files will be stored here.

    /etc/NetworkManager
    /etc/NetworkManager/system-connections

User settings are defined as files in those directories that include specific access controls to limit the access to a specific user.


* To check if Network Manager is managing any network interface, you can use nmcli, which is a command line utility that comes with Network Manager
```bash
nmcli dev status
```


## [NetworkManager and netplan](https://ubuntu.com/core/docs/networkmanager/networkmanager-and-netplan)
YAML backend
As of core20 the network-manager snap was modified to use a YAML backend by default, based upon libnetplan functionality. This YAML backend replaces NetworkManager’s native keyfile format and stores any configuration in /etc/netplan/*.yaml, to stay compatible with the rest of the system.

Eg:
```bash
/etc/netplan/00-installer-config.yaml
```

On boot the netplan.io generator processes all of the YAML files and renders them into the corresponding NetworkManager configuration in /run/NetworkManager/system-connections. The usual netplan generate/try/apply can be used to re-generate this configuration after the YAML was modified.

If a connection profile is modified or created from within NetworkManager, e.g. to update a WiFi password via nmcli, NetworkManager will create an ephemeral keyfile that will be converted to netplan YAML right away and stored in /etc/netplan. After that NetworkManager will automatically call netplan generate to re-process the current YAML configuration and render it into NM connection profiles in /run/NetworkManager/system-connections.

The system wide network configuration can be read, using the netplan get command and modified via netplan set or snapd. Configuration options that are not supported by the NetworkManager YAML backend are stored in a networkmanager.passthrough YAML mapping, so that they won’t be lost during the netplan conversion.



## Disable Network Manager for a Particular Network Interface on Debian, Ubuntu or Linux Mint
To disable Network Manager only for eth1 on Debian, Ubuntu or Linux Mint, you can do the following.

* First open the Network Manager configuration file in /etc/NetworkManager with a text editor, and set managed=false, typically shown under [ifupdown].

```bash
sudo vi /etc/NetworkManager/NetworkManager.conf
[ifupdown]
managed=false
```

* Second in /etc/network/interfaces, add information about the interface you want to disable Network Manager for. In this example, the interface is eth1, and we are using static IP configuration.

```bash
sudo vi /etc/network/interfaces
```

    # The loopback network interface
    auto lo
    iface lo inet loopback

    # network interface not managed by Network Manager
    allow-hotplug eth1
    iface eth1 inet static
    address 10.0.0.10
    netmask 255.255.255.0
    gateway 10.0.0.1
    dns-nameservers 8.8.8.8

* Third disable network-manager
```bash
sudo systemctl stop NetworkManager.service
sudo systemctl disable NetworkManager.service
```




## Plain Old Networking
Interfaces are managed in the file: /etc/network/interfaces

```bash
# network interface not managed by Network Manager
allow-hotplug eth1
iface eth1 inet static
address 10.0.0.10
netmask 255.255.255.0
gateway 10.0.0.1
dns-nameservers 8.8.8.8
```

# KVM Networking
There are a few different ways to allow a virtual machine access to the external network.

1. The default virtual network configuration is known as Usermode Networking. NAT is performed on traffic through the host interface to the outside network.

2. Alternatively, you can configure Bridged Networking to enable external hosts to directly access services on the guest operating system.


## Bridge interfaces
Bridged networking allows the virtual interfaces to connect to the outside network through the physical interface, making them appear as normal hosts to the rest of the network.

Warning: Network bridging will not work when the physical network device (e.g., eth1, ath0) used for bridging is a wireless device (e.g., ipw3945), as most wireless device drivers do not support bridging!

https://help.ubuntu.com/community/KVM/Networking#Bridged_Networking



### Creating a network bridge on the host
You can set up your system to boot with a bridge. This disables network manager. You can also create a bridge on demand. This allows network manager to stay, but you have to remember to start the bridge before starting the VMs which use it. (Autostarted VMs can not use this)

#### Creating a bridge on demand
You can do this from the command line or a script. Details are covers on the Network Connection Bridge page.

You can use Network Manger to set up your bridge. This is covered in a website at ask.xmodulo.com/configure-linux-bridge-network-manager-ubuntu.html.

#### Creating a persistent bridge
Install the bridge-utils package:

```bash
sudo apt-get install bridge-utils
```

We are going to change the network configuration. This assumes you are not using NetworkManager to control your network cards (eth0 in the example's case). Modifying /etc/network/interfaces will disable Network Manager on the next reboot.

If you are on a remote connection, and so cannot stop networking, go ahead with the following commands, and use 
```bash
sudo invoke-rc.d networking restart
``` or 
```bash
sudo reboot at the end. 
```
If you make a mistake, though, it won't come back up.


To set up a bridge interface, edit /etc/network/interfaces and either comment or replace the existing config with (replace with the values for your network):

```bash
auto lo
iface lo inet loopback

auto br0
iface br0 inet static
        address 192.168.0.10
        network 192.168.0.0
        netmask 255.255.255.0
        broadcast 192.168.0.255
        gateway 192.168.0.1
        dns-nameservers 192.168.0.5 8.8.8.8
        dns-search example.com
        bridge_ports eth0
        bridge_stp off
        bridge_fd 0
        bridge_maxwait 0
```


* show bridges
```bash
brctl show

```

* remove a bridge interface
```bash
ip link set <brNIC> down
brctl delbr <brNIC>
```

Or

```bash
sudo ip link delete br0 type bridge
```


### IP Aliases
https://help.ubuntu.com/community/KVM/Networking#Bridged_Networking

IP aliases provide a convenient way to give VM guests their own external IPs:

1. Set up bridged networking.

2. Create necessary IP aliases in the host as usual: put in /etc/network/interfaces, e.g.,

auto eth0:0
iface eth0:0 inet static
address 192.168.0.11
netmask 255.255.255.0
3. Hardwire the guest's IP, either changing it to static, e.g., as 192.168.122.99, in /etc/network/interfaces in the guest or with a host entry in dhcp configuration (see below).

4. Enable routing in the host: uncomment net.ipv4.ip_forward=1 in /etc/sysctl.conf (/etc/ufw/sysctl.conf if using ufw), or temporarily with echo 1 >/proc/sys/net/ipv4/ip_forward.

5. Change virtlib forward from 'nat' to 'route' and adjust dhcp range to exclude the address used for guest (optionally, add host entry for it): 
'virsh net-edit default' 
and change the xml to something like this:

```bash
virsh net-edit default
```


<network>
  <name>default</name>
  <uuid>12345678-1234-1234-1234-123456789abc</uuid>
  <forward mode='route'/>
  <bridge name='virbr0' stp='on' delay='0' />
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.100' end='192.168.122.254' />
      <host mac"=00:11:22:33:44:55" name="guest.example.com" ip="192.168.122.99" />
    </dhcp>
  </ip>
</network>


**DONT DO THIS**
6. Direct traffic from external interface to internal and back:

```bash
iptables -t nat -A PREROUTING -d 192.168.0.11 -j DNAT --to-destination 192.168.122.99
iptables -t nat -A POSTROUTING -s 192.168.122.99 -j SNAT --to-source 192.168.0.11
```
Where to put those depends on your firewall setup; if you use ufw you might use /etc/ufw/before.rules. You might also need to adjust your firewall filtering rules.

**NOTE -** these break things so you cant get into the parent host (the one hostting the vms)
It makes it so you when you try to login to the parent host you go straight to the VM setup in the forwarding below
```bash
virsh  net-edit default
sudo vi /etc/sysctl.conf
sudo iptables -t nat -A PREROUTING -d 10.240.0.2 -j DNAT --to-destination 192.168.122.10
sudo iptables -t nat -A POSTROUTING -s 192.168.122.10 -j SNAT --to-source 10.240.0.2

```

**Do this**
```bash
sudo iptables -A FORWARD -i virbr0 -o enp5s0f0 -j ACCEPT
sudo iptables -A FORWARD -i enp5s0f0 -o virbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o enp5s0f0 -j MASQUERADE
```



## Real or VLAN interfaces
* Permanently add interfaces and ip address to the host in the `/etc/network/interfaces` file

```bash
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


## Stopping and Disabling NetworkManager
Using Systemd
Systemd became the default initialization system in Ubuntu 15.04. Here's how to stop and disable Network Manager without uninstalling it (taken from AskUbuntu):

* Stop network manager
```bash
sudo systemctl stop NetworkManager.service
sudo systemctl stop NetworkManager-wait-online.service
sudo systemctl stop NetworkManager-dispatcher.service
sudo systemctl stop network-manager.service
```

* Disable network manager (permanently) to avoid it restarting after a reboot
```bash
sudo systemctl disable NetworkManager.service
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl disable NetworkManager-dispatcher.service
sudo systemctl disable network-manager.service
```


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

* Permanently add interfaces and ip address to the host see [Real or VLAN interfaces](Real or VLAN interfaces)


* bring up the nic

```
sudo ifconfig enp2s0.200 up
```

# bonding and port channels
* setup the bond as 802.3ad
