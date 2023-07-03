# What

<br>

# PreReqs

<br>

## Setup Bridge Networking

Setup bridged networking with a permanent bridge to be able to get out from the vms.

Bridged networking allows the virtual interfaces to connect to the outside network through the physical interface, making them appear as normal hosts to the rest of the network.

https://help.ubuntu.com/community/KVM/Networking#Bridged_Networking

### Create Network Bridge

Set up system to boot with a bridge. This disables network manager.

1. Install the bridge-utils package:

```bash
sudo apt-get install bridge-utils
```

Change the network configuration. This assumes NetworkManager is not being used to control the network cards. Modifying /etc/network/interfaces will disable Network Manager on the next reboot.

If you are on a remote connection, and so cannot stop networking, use the following command:

```bash
sudo invoke-rc.d networking restart
```

or if you are done and ready to apply changes:

```bash
sudo reboot
```

If you make a mistake, though, it won't come back up.

2.  Set up a bridge interface, edit /etc/network/interfaces and either comment or replace the existing config with (replace with the values for your network):

```bash
auto lo
iface lo inet loopback

auto br0
iface br0 inet static
```

- if needed get the gateway

```bash
ip r
```

the first line indicates the gateway on the network:

    default via 172.23.15.254 dev

- show bridges

```bash
brctl show
```

<br>

### Disable Bridge Filtering

https://wiki.libvirt.org/Net.bridge.bridge-nf-call_and_sysctl.conf.html

The tunables in item 2 below control whether or not packets traversing the bridge are sent to iptables for processing.

In the case of using bridges to connect virtual machines to the network, generally such processing is _not_ desired, as it results in guest traffic being blocked due to host iptables rules that only account for the host itself, and not for the guests.

1. Create if necessary and add the content below to the file _/etc/udev/rules.d/99-bridge.rules_:

```bash
ACTION=="add", SUBSYSTEM=="module", KERNEL=="br_netfilter", RUN+="/usr/lib/systemd/systemd-sysctl --prefix=net/bridge
```

2. Create if necessary and add the content below to the file /etc/sysctl.d/bridge.conf:

```bash
net.bridge.bridge-nf-call-arptables = 0
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
```

3. Reboot or reload udev and sysctl.

<br>

### KVM Host IP Forwarding

https://help.ubuntu.com/community/KVM/Networking#Bridged_Networking

1. Set up bridged networking. (should already be done from the steps above)

2. Enable IP forwarding on the kvm host in order for it to function as a router; to receive and forward packets.

Once this is done, devices on internal networks should be able to communicate.

- Uncomment the line **net.ipv4.ip_forward=1** in the _/etc/sysctl.conf_ configuration file.

Check first if the line is already defined on the configuration file;

```bash
grep net.ipv4.ip_forward /etc/sysctl.conf
#net.ipv4.ip_forward=1
```

- if the line is present and commented out, uncomment by running the command below:

```bash
sudo su root
sed -i '/net.ipv4.ip_forward/s/^#//' /etc/sysctl.conf
```

Otherwise, just insert the line;

```bash
sudo su root
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
```

- Apply the changes;

```bash
sudo sysctl -p
```

- Check the status by running the command below;

```bash
sysctl net.ipv4.ip_forward
```

Value should be 1.

NOTE: Optional not sure this is required 3. Change virtlib forward from 'nat' to 'route' and adjust dhcp range to exclude the addresses used for guest (optionally, add host entry for it) change the xml to something like this:

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
        </dhcp>
    </ip>
    </network>

<br>
<br>

# KVM installation

## KVM Host Setup

```bash
sudo apt update && sudo apt upgrade -y
sudo apt update
```

Check if the server supports Virtualization Technology (VT).

```bash
sudo apt install -y libvirt-clients
sudo virt-host-validate
```

The validation tool will report the following warning message if the server has Intel processors. It is expected because the validation tool does not check Secure Guest on Intel processors:

    QEMU: Checking for secure guest support: WARN (Unknown if this platform has Secure Guest support)

If the server has Intel processors with only VT-x (vmx) support but no VT-d support, the validation tool will report the following warning message that you can ignore:

    QEMU: Checking for device assignment IOMMU support: WARN (No ACPI DMAR table found, IOMMU either disabled in BIOS or not supported by this hardware platform)

You may also see the following warning message from the validation tool for Intel processors:

    QEMU: Checking if IOMMU is enabled by kernel: WARN (IOMMU appears to be disabled in kernel. Add intel_iommu=on to kernel cmdline arguments)

If needed enable IOMMU in your GRUB boot parameters. Do this by setting the following in /etc/default/grub:

```bash
GRUB_CMDLINE_LINUX_DEFAULT=”intel_iommu=on”
```

Then update the GRUB and reboot the server:

```bash
sudo update-grub
sudo reboot
```

## Installation of KVM

Run the following command to install KVM and associated VM management packages:

```bash
sudo apt install -y qemu-kvm libvirt-daemon-system bridge-utils virtinst
```

Verify the libvirt daemon is active and enabled:

```bash
sudo systemctl status libvirtd
```

Run the following command to install cloud image management utilities, cloud-image-utils:

```bash
sudo apt install -y cloud-image-utils
```

Add your local user to the kvm and libvirt groups:

```bash
sudo usermod -aG kvm $USER
sudo usermod -aG libvirt $USER
```

Log out and log back in to make the new group membership available.

## Get Ubuntu Server Cloud Image

Create a directory for storing downloaded cloud images:

```bash
sudo mkdir -p /var/kvm/base
sudo chmod -R go+rwx /var/kvm/
cd /var/kvm/base
```

Download Ubuntu Server 22.04 Cloud Image:

```bash
#wget -P . https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
wget -P . https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
```

Create directories for the Guest VM instance images:

```bash
export VM_HOSTNAME=k8-ctl-02-dev
cd /var/kvm/
mkdir $VM_HOSTNAME
```

Create a disk image, $VM_HOSTNAME.qcow2, with XYZ GB virtual size based on the Ubuntu server 22.04 cloud image:

```bash
qemu-img create -F qcow2 -b /var/kvm/base/jammy-server-cloudimg-amd64.img -f qcow2 /var/kvm/$VM_HOSTNAME/$VM_HOSTNAME.qcow2 20G
```

    Formatting '/var/kvm/k8-ctl-02-dev/k8-ctl-02-dev.qcow2', fmt=qcow2 cluster_size=65536 extended_l2=off compression_type=zlib size=21474836480 backing_file=/var/kvm/base/jammy-server-cloudimg-amd64.img backing_fmt=qcow2 lazy_refcounts=off refcount_bits=16

## VM Guest Network Configuration

Use an internal Bash function, $RANDOM, to generate a MAC address and write it to an environment variable, MAC_ADDR.

For KVM VMs it is required that the first 3 pairs in the MAC address be the sequence 52:54:00:

```bash
export MAC_ADDR=$(printf '52:54:00:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
echo $MAC_ADDR
```

    52:54:00:fa:e6:de

Define the ethernet interface name and the internal IP address to be used in the VM:

```bash
export INTERFACE=enp1s0
export IP_ADDR=192.168.122.12
```

Create a network configuration file _network-config_:

```bash
cat > $VM_HOSTNAME/network-config <<EOF
ethernets:
    $INTERFACE:
        addresses:
        - $IP_ADDR/24
        dhcp4: false
        gateway4: 192.168.122.1
        match:
            macaddress: $MAC_ADDR
        nameservers:
            addresses:
            - 8.8.8.8
        set-name: $INTERFACE
version: 2
EOF
```

## VM Guest Cloud-Init Configuration

Cloud-init allows many post OS creation modifications to be done like the creation of user accounts and package installations.

Create _user-data_:

NOTE: If there are $ in the passwd hash they will need to be escaped with a back slash

```bash
cat > $VM_HOSTNAME/user-data <<EOF
#cloud-config
hostname: $VM_HOSTNAME
users:
  - default
  - name: jay
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    home: /home/jay
    shell: /bin/bash
    plain_text_passwd: 'your_plain_text_password_here'
    lock_passwd: false
    ssh_authorized_keys: <contents of your ssh .pub key here>
ssh_pwauth: true
disable_root: false

package_upgrade: true

packages:
 - net-tools
 - vlan
 - mlocate
 - git
 - vim
 - python3-pip

EOF
```

Create meta-data:

```bash
touch meta-data
```

Create a the seed disk image, $VM_HOSTNAME-seed.qcow2 to attach with the network and cloud-init configuration:

```bash
cloud-localds -v --network-config=$VM_HOSTNAME/network-config /var/kvm/$VM_HOSTNAME/$VM_HOSTNAME-seed.qcow2 $VM_HOSTNAME/user-data meta-data
```

    wrote /var/kvm/k8-ctl-02-dev/k8-ctl-02-dev-seed.qcow2 with filesystem=iso9660 and diskformat=raw

ip route

## Provision New Guest VM

Create and start a new guest VM with two disks attached, $VM_HOSTNAME.qcow2 and $VM_HOSTNAME-seed.qcow2:

```bash
virt-install --connect qemu:///system --virt-type kvm --name $VM_HOSTNAME --ram 8192 --vcpus=2 --os-variant ubuntu22.04 --disk path=/var/kvm/$VM_HOSTNAME/$VM_HOSTNAME.qcow2,device=disk --disk path=/var/kvm/$VM_HOSTNAME/$VM_HOSTNAME-seed.qcow2,device=disk --import --network network=default,model=virtio,mac=$MAC_ADDR --noautoconsole
```

    Starting install...
    Creating domain...                                                                                                                                                                                                                                |    0 B  00:00:00
    Domain creation completed.

Check if the guest VM, $VM_HOSTNAME, is running:

```bash
virsh list
```

    Id   Name                  State
    -------------------------------------
    1    k8-ctl-02-dev   running

Use the command from the KVM host (host where vms are created on) to login to the guest VM (the newly created vm) console:

```bash
virsh console k8-ctl-02-dev
```

Type control + shift + ] to exit the guest VM console.

    n-k8s-02-dev 03:52:30 /var/kvm{37} virsh console k8-ctl-02-dev
    Connected to domain k8-ctl-02-dev
    Escape character is ^]

- Hit enter a couple of times and the login prompt comes up
- password is the same as the user name as per the lines in the _user-data_ file

NOTE: cloud-init is going to run and perform its actions as specified in the user-data file

```bash
n-k8s-02-dev login: jay
Password:
Welcome to Ubuntu 22.04.2 LTS (GNU/Linux 5.15.0-73-generic x86_64)
```

Use the command from the guest VM to verify the network interface name, IP address and MAC address:

```bash
jay@n-k8s-02-dev:~$ ip addr show
```

If everything is in order, you can connect to the guest VM using ssh from the KVM host:

```bash
ssh jay@192.168.122.12
```

### Fix/Change Guest VM network

NOTE: Optional not sure this is actually required

To have virtual machines use the bridge, the guest XML block below should be used:

Edit the guest vm XML file

```bash
virsh edit $VM_HOSTNAME
```

The xml should look something like this:

```xml
<interface type='bridge'>
   <source bridge='virbr0'/>
   <mac address='00:16:3e:1a:b3:4a'/>
   <model type='virtio'/>   # try this if you experience problems with VLANs
</interface>

```

## Destroying and Undefining Guest VM domains

Run the following commands to remove the guest KVM VM:

```bash
virsh destroy $VM_HOSTNAME
virsh undefine $VM_HOSTNAME
rm -rf /var/kvm/$VM_HOSTNAME
```

# Create /etc/hosts file

On the KVM host

```bash
sudo vi /etc/hosts
```

# SSH Keys - Passwordless ssh

If this is not already taken care of from the VM creation above (where the ssh authorized keys file is created by cloud-init and the user-data file) then from the host that has the keys:

```bash
cd ~/.ssh
cp id_ed25519.pub authorized_keys
# send the key to the server you want passwordless ssh
rsync -av ~/.ssh/authorized_keys jay@k8-ctl-02-dev:~/.ssh/
```

# Ansible

Ansible is being used to push out the _/etc/hosts_ file.
NOTE: this probably could have been done with cloud-init in the VM creation phases above

## Install

- Install ansible (if not already installed)

```
sudo apt install ansible
sudo apt install ansible-lint
```

- Install arg complete

```
sudo apt install python3-argcomplete
```

- Activate arg complete

```
sudo activate-global-python-argcomplete3
```

NOTE: Make sure the _authorized_keys_ file exists on each of the target machines for the target user

## Ansible hosts file

- Create a /etc/ansible/hosts file

```
sudo vim /etc/ansible/hosts
# add the hosts, one per line
```

- Create the playbook to push the /etc/hosts file

```bash
cat > copy_etcHosts.yml <<EOF
---
- name: Playbook to copy files
  become: true
  hosts: all

  tasks:

    - name: Copy file with owner and permissions
      copy:
        src: /etc/hosts
        dest: /etc/hosts
        owner: root
        group: root
        mode: '0644'

EOF
```

## Run the playbook

- Run the playbook created above to push the /etc/hosts file out to each node

```bash
ansible-playbook -i /etc/ansible/hosts -K copy_etcHosts.yml
```

# Create routes for the bridge virtual networks to each other

- list current routes

```bash
route -n
```

or

```bash
netstat -rn
```


## Networking Troubleshooting

telnet from a specific source IP

```bash
# telnet -b sourceIP_ADDR destIP_ADDR port#
telnet -b 192.168.121.31 192.168.122.12 10250
```

ping from a specific source IP

```bash
# ping -I sourceIP_ADDR destIP_ADDR
ping -I 192.168.121.31 192.168.122.12
```

## Temporary

On each of the KVM hosts create routes to the private bridge (virtual) networks on those hosts

- To the private network on host B via the public interface of host B
- To the private network on host A via the public interface of host A

and so on depending on how many KVM hosts and virutal networks exist in the setup

```bash
# sudo route add -net $VMprivateNetwork_HostA netmask 255.255.255.0 gw $KVMhostPublicIntfaceIPAddr_HostA
# sudo route add -net $VMprivateNetwork_HostB netmask 255.255.255.0 gw $KVMhostPublicIntfaceIPAddr_HostB
```

- on k8s-01

```bash
sudo route add -net 192.168.122.0 netmask 255.255.255.0 gw KVMhostPublicIntfaceIPAddr_HostB 
```

- on k8s-02

```bash
sudo route add -net 192.168.121.0 netmask 255.255.255.0 gw KVMhostPublicIntfaceIPAddr_HostA
```

## Permanently

1. add a line to the file _/etc/network/interfaces_

- on k8s-01

```bash
ip route add -net 192.168.122.0/24 gw KVMhostPublicIntfaceIPAddr_HostB dev eno12399np0
```

- on k8s-02

```bash
ip route add -net 192.168.121.0/24 gw KVMhostPublicIntfaceIPAddr_HostA dev eno12399np0
```

2. restart networking

```bash
sudo invoke-rc.d networking restart
```

# Port Forwarding for VM guests

[Port forwarding of incoming connections on a NAT network](https://wiki.libvirt.org/Networking.html#forwarding-incoming-connections)

After K8s pods and services are up and running, set up forwarding to the virbr0

By default, guests that are connected via a virtual network with <forward mode='nat'/> can make any outgoing network connection they like.

Incoming connections are allowed from the host, and from other guests connected to the same libvirt network, _but all other incoming connections are blocked by iptables rules_.

Steps to make a service that is on a guest behind a NATed virtual network publicly available, setup libvirt's "hook" script for qemu to install the necessary iptables rules to forward incoming connections to the host on any given port HP to port GP on the guest GNAME:

- Determine

  - a) the name of the guest "G" (as defined in the libvirt domain XML),
  - b) the IP address of the guest "I",
  - c) the port on the guest that will receive the connections "GP", and
  - d) the port on the host that will be forwarded to the guest "HP".

- Stop the guest if it's running.

```bash
virsh shutdown $VM_HOSTNAME
```

- Create the file /etc/libvirt/hooks/qemu (or add the following to an already existing hook script), with contents similar to the following (replace GNAME, IP, GP, and HP appropriately for your setup):

```bash
#!/bin/bash

# IMPORTANT: Change the "VM NAME" string to match your actual VM Name.
# In order to create rules to other VMs, just duplicate the below block and configure
# it accordingly.
if [ "${1}" = "k8-worker-02-dev" ]; then

   # Update the following variables to fit your setup
   GUEST_IP=192.168.122.32
   GUEST_PORT=32713
   HOST_PORT=32713

   if [ "${2}" = "stopped" ] || [ "${2}" = "reconnect" ]; then
    /sbin/iptables -D FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
    /sbin/iptables -t nat -D PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
   if [ "${2}" = "start" ] || [ "${2}" = "reconnect" ]; then
    /sbin/iptables -I FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
    /sbin/iptables -t nat -I PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
fi
```

<!-- ```bash
if [ "${1}" = "k8-ctl-02-dev" ]; then

   # Update the following variables to fit your setup
   GUEST_IP=192.168.121.31
   GUEST_PORT=443
   HOST_PORT=443

   if [ "${2}" = "stopped" ] || [ "${2}" = "reconnect" ]; then
    /sbin/iptables -D FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
    /sbin/iptables -t nat -D PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
   if [ "${2}" = "start" ] || [ "${2}" = "reconnect" ]; then
    /sbin/iptables -I FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
    /sbin/iptables -t nat -I PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
fi

if [ "${1}" = "k8-ctl-02-dev" ]; then

   # Update the following variables to fit your setup
   GUEST_IP=192.168.121.31
   GUEST_PORT=53
   HOST_PORT=53

   if [ "${2}" = "stopped" ] || [ "${2}" = "reconnect" ]; then
    /sbin/iptables -D FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
    /sbin/iptables -t nat -D PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
   if [ "${2}" = "start" ] || [ "${2}" = "reconnect" ]; then
    /sbin/iptables -I FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
    /sbin/iptables -t nat -I PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
fi

if [ "${1}" = "k8-ctl-02-dev" ]; then

   # Update the following variables to fit your setup
   GUEST_IP=192.168.121.31
   GUEST_PORT=53
   HOST_PORT=53

   if [ "${2}" = "stopped" ] || [ "${2}" = "reconnect" ]; then
    /sbin/iptables -D FORWARD -o virbr0 -p udp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
    /sbin/iptables -t nat -D PREROUTING -p udp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
   if [ "${2}" = "start" ] || [ "${2}" = "reconnect" ]; then
    /sbin/iptables -I FORWARD -o virbr0 -p udp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
    /sbin/iptables -t nat -I PREROUTING -p udp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
fi

if [ "${1}" = "k8-ctl-02-dev" ]; then

   # Update the following variables to fit your setup
   GUEST_IP=192.168.121.31
   GUEST_PORT=9153
   HOST_PORT=9153

   if [ "${2}" = "stopped" ] || [ "${2}" = "reconnect" ]; then
    /sbin/iptables -D FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
    /sbin/iptables -t nat -D PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
   if [ "${2}" = "start" ] || [ "${2}" = "reconnect" ]; then
    /sbin/iptables -I FORWARD -o virbr0 -p tcp -d $GUEST_IP --dport $GUEST_PORT -j ACCEPT
    /sbin/iptables -t nat -I PREROUTING -p tcp --dport $HOST_PORT -j DNAT --to $GUEST_IP:$GUEST_PORT
   fi
fi

``` -->

- change perms on the hook

```bash
chmod +x /etc/libvirt/hooks/qemu
```

- Restart the libvirtd service.

```bash
systemctl stop libvirtd

systemctl start libvirtd

systemctl status libvirtd
```

- Start the guest.

```bash
virsh start $VM_HOSTNAME
```

- Test routiung and forwarding from another vm guest on a different network on a another kvm host

```bash
k8-worker-01-dev> telnet k8-worker-02-dev 32713
Trying 192.168.122.32...
Connected to k8-worker-02-dev.
Escape character is '^]'.
```


