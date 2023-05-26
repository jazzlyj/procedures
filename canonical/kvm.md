In most cases, users can perform their tasks against KVM Virtual Machines (VM) without knowing their network configuration, such as the Media Access Control (MAC) addresses and the network interface names. KVM automatically generates a MAC address and assigns a default network interface name and a dynamic IP address for the guest VM if a user does not provide them when creating the VM.

However, it will sometimes require static or fixed values to configure some network properties before setting up a guest VM, especially when it comes to VM provisioning.

This post is a step-by-step tutorial that will help you to create a KVM VM using Ubuntu server 20.04 cloud image with the following network properties: a static MAC address, a pre-defined network interface name, and a static internal IP address.

Preparation
Re-synchronize the package index files from their sources and install the newest versions of all packages currently installed on the system:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt update 
```

You can check if the server supports Virtualization Technology (VT) in various methods. In this post, you use a tool, virt-host-validate, to validates that the server is configured in a suitable way to run libvirt hypervisor drivers:
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
The solution to this issue is to enable IOMMU in your GRUB boot parameters. You can do this by setting the following in /etc/default/grub:

  GRUB_CMDLINE_LINUX_DEFAULT=”intel_iommu=on”

Then update the GRUB and reboot the server:

```bash
sudo update-grub
sudo reboot
```

# Installation of KVM and Associate Packages
Run the following command to install KVM and associate VM management packages:
```bash
sudo apt install -y qemu-kvm \
                      libvirt-daemon-system \
                      bridge-utils \
                      virtinst
```

You can verify if the libvirt daemon is active and enabled:
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


# Ubuntu Server Cloud Image
Create a directory for storing downloaded cloud images:
```bash
mkdir -p $HOME/kvm/base
# or
sudo mkdir -p /local/mnt/kvm/base
sudo chmod -R go+rwx /local/mnt/kvm/
cd /local/mnt/kvm/base
```

Download Ubuntu Server 20.04 Cloud Image:
```bash
wget -P $HOME/kvm/base https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
# 
wget -P . https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
```

Create another directory for your VM instance images:
```bash
mkdir -p $HOME/kvm/vm01
#
mkdir -p /local/mnt/kvm/k8-ctl-2
#
cd /local/mnt/kvm/
mkdir $VM_HOSTNAME
```

Create a disk image, $VM_HOSTNAME.qcow2, with XYZ GB virtual size based on the Ubuntu server 20.04 cloud image:
```bash
qemu-img create -F qcow2 -b ~/kvm/base/focal-server-cloudimg-amd64.img -f qcow2 ~/kvm/vm01/vm01.qcow2 10G
#
qemu-img create -F qcow2 -b /local/mnt/kvm/base/focal-server-cloudimg-amd64.img -f qcow2 /local/mnt/kvm/k8-ctl-2/k8-ctl-2.qcow2 50G
#
qemu-img create -F qcow2 -b /local/mnt/kvm/base/focal-server-cloudimg-amd64.img -f qcow2 /local/mnt/kvm/$VM_HOSTNAME/$VM_HOSTNAME.qcow2 70G

```

# Network Configuration
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
export IP_ADDR=192.168.122.11
export VM_HOSTNAME=k8-ctl-2
```

Create a network configuration file *network-config*:
```bash
cat >network-config <<EOF
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
            - 1.1.1.1
            - 8.8.8.8
        set-name: $INTERFACE
version: 2
EOF
```

# Cloud-Init Configuration
Cloud-init allows many post OS creation modifications to be done like the creation of user accounts and package installations. 

Create *user-data*:
```bash
cat >user-data <<EOF
#cloud-config
hostname: $VM_HOSTNAME
manage_etc_hosts: true
users:
  - name: jay
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    home: /home/jay
    shell: /bin/bash
    lock_passwd: false
ssh_pwauth: true
disable_root: false
chpasswd:
  list: |
    jay:jay
  expire: false

package_upgrade: true

packages:
 - net-tools
 - vlan
 - mlocate
 - git
 - vim
 - python3-pip

runcmd:
  - cd /home/jay
  - [git, clone, "https://github.com/jazzlyj/dotfiles.git"]
  - cp /home/jay/dotfiles/.bash_aliases /home/jay
  - cp /home/jay/dotfiles/.profile.local /home/jay
  - echo . ~/.profile.local >> /home/jay/.profile
  - chown -R jay:jay /home/jay
EOF
```

Create meta-data:
```bash
touch meta-data
```

Create a the seed disk image, $VM_HOSTNAME-seed.qcow2 to attach with the network and cloud-init configuration:
```bash
cloud-localds -v --network-config=network-config ~/kvm/vm01/vm01-seed.qcow2 user-data meta-data
# or
cloud-localds -v --network-config=network-config /local/mnt/kvm/k8-ctl-2/k8-ctl-2-seed.qcow2 user-data meta-data
#
cloud-localds -v --network-config=network-config /local/mnt/kvm/$VM_HOSTNAME/$VM_HOSTNAME-seed.qcow2 user-data meta-data

```

      jay@u2:/local/mnt/kvm$ cloud-localds -v --network-config=network-config /local/mnt/kvm/k8-ctl-2/k8-ctl-2-seed.qcow2 user-data meta-data
      wrote /local/mnt/kvm/k8-ctl-2/k8-ctl-2-seed.qcow2 with filesystem=iso9660 and diskformat=raw
    

# Provision a New Guest VM
Create and start a new guest VM with two disks attached, $VM_HOSTNAME.qcow2 and $VM_HOSTNAME-seed.qcow2:
```bash
virt-install --connect qemu:///system --virt-type kvm --name vm01 --ram 2048 --vcpus=2 --os-type linux --os-variant ubuntu20.04 --disk path=$HOME/kvm/vm01/vm01.qcow2,device=disk --disk path=$HOME/kvm/vm01/vm01-seed.qcow2,device=disk --import --network network=default,model=virtio,mac=$MAC_ADDR --noautoconsole
#
virt-install --connect qemu:///system --virt-type kvm --name k8-ctl-2 --ram 4096 --vcpus=2 --os-type linux --os-variant ubuntu20.04 --disk path=/local/mnt/kvm/k8-ctl-2/k8-ctl-2.qcow2,device=disk --disk path=/local/mnt/kvm/k8-ctl-2/k8-ctl-2-seed.qcow2,device=disk --import --network network=default,model=virtio,mac=$MAC_ADDR --noautoconsole
#
virt-install --connect qemu:///system --virt-type kvm --name $VM_HOSTNAME --ram 8192 --vcpus=2 --os-type linux --os-variant ubuntu20.04 --disk path=/local/mnt/kvm/$VM_HOSTNAME/$VM_HOSTNAME.qcow2,device=disk --disk path=/local/mnt/kvm/$VM_HOSTNAME/$VM_HOSTNAME-seed.qcow2,device=disk --import --network network=default,model=virtio,mac=$MAC_ADDR --noautoconsole
```

      Starting install...
      Domain creation completed.
    

Check if the guest VM, vm01, is running:
```bash
virsh list
```

      jay@u2:/local/mnt/kvm$ virsh list
      Id   Name       State
      --------------------------
      1    k8-ctl-1   running
      2    k8-ctl-2   running
    


Use the command from the KVM host (host where vms are created on) to login to the guest VM (the newly created vm) console:
```bash
# virsh console $VM_HOSTNAME

virsh console k8-ctl-2
```
Type control + shift + ] to exit the guest VM console.


```bash
jay@u2:/local/mnt/kvm$ virsh console k8-ctl-2
Connected to domain k8-ctl-2
Escape character is ^]
```

* Hit enter a couple of times and the login prompt comes up 
* password is the same as the user name as per the lines in the *user-data* file 


```bash
k8-ctl-2 login: jay
Password: 
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-148-generic x86_64)
```



Use the command from the guest VM to verify the network interface name, IP address and MAC address:
```bash
jay@k8-ctl-2:~$ ip addr show
```




If everything is in order, you can connect to the guest VM using ssh from the KVM host:
```bash
ssh vmadm@192.168.122.101
ssh jay@192.168.122.11
```


Final Notes
Run the following commands to remove the guest KVM VM:
```bash
virsh destroy vm01
virsh undefine vm01
rm -rf ~/kvm/vm01
```
The network configuration file, network-config, is parsed, written, and applied to the guest VM as a netplan file. The netplan file is very selective about indentation, spacing, and no tabs. See the following link for additional help:

https://netplan.io/examples
The guest VM will get an IP address in the 192.168.122.0/24 address space in the default KVM network configuration. NAT is performed on traffic through a private bridge to the outside network. The guest VMs, however, will not be visible to other machines on the network. You can set up KVM to use a public bridge to make guest VMs appear as normal hosts to the rest of the network.


https://yping88.medium.com/use-ubuntu-server-20-04-cloud-image-to-create-a-kvm-virtual-machine-with-fixed-network-properties-62ecae025f6c