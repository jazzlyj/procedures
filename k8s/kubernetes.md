# K8s standalone

## PreReqs 
* disable swap



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

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

```
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```
sudo apt-get install -y docker.io
docker -v
sudo docker run hello-world
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```

```
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee / etc/apt/sources.list.d/kubernetes.list
```

```
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

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
* Copy and past all env vars into the command line from the file: kubeadmExportParams
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
MASTER_SSH_ADDR_1=<yourusername>@apiNode2
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




