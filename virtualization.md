https://ubuntu.com/server/docs/virtualization-libvirt

# Step 0: prereqs
* make sure ssh keys are installed and ssh-agent is running (with the private key)
* good idea to setup 


# Step 1: Install required packages
On your Ubuntu 20.04 execute the following command to install the required packages:

```bash
sudo apt -y install bridge-utils cpu-checker libvirt-clients libvirt-daemon libvirt-daemon-system qemu qemu-kvm
```

# Step 2: verify
```bash
kvm-ok
```


# Step 3: create a vm
Gives a interactive GUI to go through ubuntu installation.
* Create username and password.
 


# Step 4: VM management
on another host install virt-manager


## [Virtualisation tools](https://ubuntu.com/server/docs/virtualization-virt-tools#libvirt-virt-manager)
The virt-manager source contains not only virt-manager itself but also a collection of further helpful tools like virt-install, virt-clone and virt-viewer.

## Virtual Machine Manager

The virt-manager package contains a graphical utility to manage local and remote virtual machines. To install virt-manager, enter:

```bash
sudo apt install virt-manager
```
Since virt-manager requires a Graphical User Interface (GUI) environment it is recommended to install it on a workstation or test machine instead of a production server. To connect to the local libvirt service enter:

```
virt-manager
```

You can connect to the libvirt service running on another host by entering the following in a terminal prompt:

```bash
virt-manager -c qemu+ssh://host-with-kvm-installed/system
```