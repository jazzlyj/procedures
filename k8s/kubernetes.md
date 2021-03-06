# K8s standalone

## PreReqs 
* [disable swap](../canonical/ubuntu20.md#disable-swap-for-k8s)


## K8s install and setup
```
sudo cat /sys/class/dmi/id/product_uuid
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
```

```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
```



### Container Runtimes
#### Containerd
Use the following commands to install Containerd on your system.

* Install and configure prerequisites:
```
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
```

* Install containerd by way of docker
Install docker to get containerd
https://docs.docker.com/engine/install/ubuntu/

 * uninstall old verions first
```
sudo apt-get remove docker docker-engine docker.io containerd runc
```

 * install needed prereqs
```
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

 * get keyring
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

 * add keyring
```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```


 * update and install docker and containerd
```
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```


* Configure containerd
```
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
```

* Restart containerd:
```
sudo systemctl restart containerd
```



* Using the systemd cgroup driver in /etc/containerd/config.toml with runc, set
```
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```

* Restart containerd again:
```
sudo systemctl restart containerd
```



????
```
docker -v
sudo docker run hello-world
```


### Install kubeadm, kubelet and kubectl
* Update the apt package index and install packages needed to use the Kubernetes apt repository:
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
```

* Download the Google Cloud public signing key:
```
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```

* Add the Kubernetes apt repository:
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
```
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

* Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
```
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```


#### Configuring the kubelet cgroup driver
https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/

Note: In v1.22, if the user is not setting the cgroupDriver field under KubeletConfiguration, kubeadm will default it to systemd.
























????
```
sudo sysctl --system
sudo ufw allow 6443/tcp
sudo ufw allow 2379/tcp
sudo ufw allow 2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp
sudo apt install mlocate
sudo apt install git
sudo apt install vim
sudo apt install net-tools
sudo apt-get update
sudo apt-get install     ca-certificates     curl     gnupg     lsb-release
```

???
# change docker to use systemd cgroup
* create (or edit) the /etc/docker/daemon.json configuration file, include the following:
```
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```
* Save the file and restart docker service.
```
sudo systemctl restart docker
```



















----------
https://medium.com/@kosta709/kubernetes-by-kubeadm-config-yamls-94e2ee11244
# kubeadm init config template
* create a kubeadm-init-config.tmpl.yaml like this:
```

```

# Input Params
* Copy and paste all env vars into the command line from the file: k8sShellParams.sh
  * Example here: 
```
# export addresses and other vars
set -a
K8S_API_ENDPOINT=apiNode1.mydomain.io
K8S_API_ENDPOINT_INTERNAL=apiNode2.mydomain.io
K8S_API_ADDVERTISE_IP_1=apiNode1
K8S_VERSION=1.23.3
K8S_CLUSTER_NAME=pickAname
K8S_MASTER=master1Name
OUTPUT_DIR=$(realpath -m ./_clusters/${K8S_CLUSTER_NAME})
LOCAL_CERTS_DIR=${OUTPUT_DIR}/pki
KUBECONFIG=${OUTPUT_DIR}/kubeconfig
mkdir -p ${OUTPUT_DIR}
MASTER_SSH_ADDR_1=<yourusername>@k8m1
set +a
```

# Generate kubeadm token
```
export KUBEADM_TOKEN=$(kubeadm token generate)
```

# Applying parameters to the template 
```
envsubst < kubeadm-init-config.tmpl.yaml > ${OUTPUT_DIR}/kubeadm-init-config.yaml
```

# Generate Certificates
```
kubeadm init phase certs all --config ${OUTPUT_DIR}/kubeadm-init-config.yaml
```

# Generate CA Certificate Hash
```
export CA_CERT_HASH=$(openssl x509 -pubkey -in ${LOCAL_CERTS_DIR}/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* /sha256:/')
```


# Generate kubeconfig for accessing cluster by public k8s endpoint
* get file: generate-admin-client-certs.sh 
```
chmod u+x generate-admin-client-certs.sh 
./generate-admin-client-certs.sh 
```
*  set more env vars
```
set -a
CLIENT_CERT_B64=$(base64 -w0  < $LOCAL_CERTS_DIR/kubeadmin.crt)
CLIENT_KEY_B64=$(base64 -w0  < $LOCAL_CERTS_DIR/kubeadmin.key)
CA_DATA_B64=$(base64 -w0  < $LOCAL_CERTS_DIR/ca.crt)
set +a
```

* execute var subst with template
```
envsubst < kubeconfig-template.yaml > ${OUTPUT_DIR}/kubeconfig
```


# Install prerequisites on master
```
envsubst < kubeadm-prepare-master-ubuntu-tmpl > ${OUTPUT_DIR}/prepare-master.sh
```

*if on the k8 master and run this command
```
sudo bash -s < ${OUTPUT_DIR}/prepare-master.sh
```

* or ssh to the master
```
ssh $MASTER_SSH_ADDR_1 'sudo bash -s' < ${OUTPUT_DIR}/prepare-master.sh
```

# Copy certificates to correct location on the master
```
sudo mkdir -p /etc/kubernetes/; cd /etc/kubernetes/
sudo cp -r $LOCAL_CERTS_DIR .
```

# Copy the kubeadm config to the correct location                 
* Copy kubeadm config file removing certificatesDir that points to $LOCAL_CERTS_DIR
```
sed '/certificatesDir:/d' $OUTPUT_DIR/kubeadm-init-config.yaml | sudo dd of=/root/kubeadm-init-config.yaml
```

# Run kubeadm init without certs phase
```
sudo kubeadm init --skip-phases certs --config /root/kubeadm-init-config.yaml
```
