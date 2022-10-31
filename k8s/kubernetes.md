# K8s Install procedure
https://github.com/Praqma/LearnKubernetes/blob/master/kamran/Kubernetes-The-Hard-Way-on-BareMetal.md

## Build VMS
* 3 controllers
* 3 etcd hosts
* 2 load balancers
* 3 workers

## update /etc/hosts
* (opt) MAAS controlled hosts remove 'update_etc_hosts' from 
```
sudo vim /etc/cloud/cloud.cfg
```

* add all hosts to /etc/hosts
```
sudo vim /etc/hosts
# add all hosts to each nodes file
```


## disable the firewall (if running)
```
sudo ufw status
# Status: inactive
```

* Disable if active:
```
sudo ufw disable
```


## Configure / setup TLS certificates for the cluster
Reference: https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/02-certificate-authority.md

* on the primary controller get cfssl and cfssljson
```
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
chmod +x cfssl_linux-amd64
sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl

wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x cfssljson_linux-amd64
sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
```

### create certificate authority
* Create CA CSR config file:
```
echo '{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}' > ca-config.json
```

* Generate CA certificate and CA private key:
```
echo '{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "SanDiego",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "California"
    }
  ]
}' > ca-csr.json
```

* generate CA certificate and it's private key:
```
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
```

### Generate the single Kubernetes TLS certificate:

* set env var for k8s public IP to the same number ending in 0 as the controllers address
Eg: controllers are .51 and .52 so use the .50 address
```
export KUBERNETES_PUBLIC_IP_ADDRESS=X.Y.Z.50
```

* Create Kubernetes certificate CSR config file
```


```


* Generate the Kubernetes certificate and private key:
```


```

* copy private copy and turn on ssh-agent on controller1 (where you have generated all the certs and will scp them from to all the other ndoes)
see [passwordless-ssh](../ssh.md#passwordless-ssh)
```
controller1 03:14:26 ~/.ssh{7} rsync -av jay@u1:~/.ssh/id_ed25519 .
controller1 03:15:36 ~/.ssh{8} ssha
```

* copy all cert files to the other hosts
```
controller1 03:16:47 ~{11} for i in etcd1 etcd2 etcd3 controller2 worker1 worker2 worker3 lb1 lb2; do scp ca.pem kubernetes-key.pem kubernetes.pem ${i}:/home/jay ; done
```


## Configure etcd nodes


* download and install latest etcd on all etcd hosts
ver 3.5.2 as of 2/20/2022
```
wget -q --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v3.5.2/etcd-v3.5.2-linux-amd64.tar.gz"

# curl -L https://github.com/coreos/etcd/releases/download/v3.5.2/etcd-v3.5.2-linux-amd64.tar.gz -o etcd-v3.5.2-linux-amd64.tar.gz

{
tar zxvf etcd-v3.5.2-linux-amd64.tar.gz
sudo mv etcd-v3.5.2-linux-amd64/etcd* /usr/local/bin
}
```

* move cert into place
```
{
  sudo mkdir -p /etc/etcd /var/lib/etcd
  sudo chmod 700 /var/lib/etcd
  sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
}
```

* do this on each etcd node
Note: Make sure to change the IP below to the one belonging to the etcd node you are configuring.
```
export INTERNAL_IP='10.10.1.X'
export ETCD_NAME=$(hostname -s)
```


* Create the etcd systemd unit file:

```
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller1=https://10.10.1.51:2380,controller2=https://10.10.1.52:2380,controller3=https://10.10.1.53:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```


* Start etcd:
```
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
```

* set endpoint env vars
```
export ETCDCTL_API=3
HOST_1=10.10.1.31
HOST_2=10.10.1.32
HOST_3=10.10.1.33
ENDPOINTS=$HOST_1:2379,$HOST_2:2379,$HOST_3:2379
```


* check health
```
etcdctl --write-out="table" member list
etcdctl --write-out="table" endpoint health
etcdctl --write-out="table" endpoint status
```







## Bootstrapping an H/A Kubernetes Control Plane

* Setup TLS certificates in each controller node:
```
sudo mkdir -p /var/lib/kubernetes
sudo mv ca.pem kubernetes-key.pem kubernetes.pem /var/lib/kubernetes/
```

* Download and install the Kubernetes controller binaries:
v1.23.3 as of 2/20/22
```
wget https://storage.googleapis.com/kubernetes-release/release/v1.23.3/bin/linux/amd64/kube-apiserver
wget https://storage.googleapis.com/kubernetes-release/release/v1.23.3/bin/linux/amd64/kube-controller-manager
wget https://storage.googleapis.com/kubernetes-release/release/v1.23.3/bin/linux/amd64/kube-scheduler
wget https://storage.googleapis.com/kubernetes-release/release/v1.23.3/bin/linux/amd64/kubectl
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/bin/
```

### Kubernetes API Server

#### Setup Authentication and Authorization
##### Authentication


#### Create the systemd unit file
* on each controller server
```
export INTERNAL_IP='10.10.1.5X'
```

* Create the systemd unit file:
```
cat > kube-apiserver.service <<"EOF"
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/bin/kube-apiserver \
  --admission-control=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota \
  --advertise-address=INTERNAL_IP \
  --allow-privileged=true \
  --apiserver-count=3 \
  --authorization-mode=ABAC \
  --authorization-policy-file=/var/lib/kubernetes/authorization-policy.jsonl \
  --bind-address=0.0.0.0 \
  --enable-swagger-ui=true \
  --etcd-cafile=/var/lib/kubernetes/ca.pem \
  --insecure-bind-address=0.0.0.0 \
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \
  --etcd-servers=https://10.10.1.31:2379,https://10.10.1.32:2379,https://10.10.1.33:2379 \
  --service-account-key-file=/var/lib/kubernetes/kubernetes.pem \
  --service-account-signing-key-file=/var/lib/kubernetes/kubernetes-key.pem \
  --service-account-issuer=https://10.10.1.50:6443 \
  --service-cluster-ip-range=10.32.0.0/24 \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \
  --token-auth-file=/var/lib/kubernetes/token.csv \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

* Substitute IP ADD
```
sed -i s/INTERNAL_IP/$INTERNAL_IP/g kube-apiserver.service
sudo mv kube-apiserver.service /etc/systemd/system/
```


* kube-scheduler - need to use v1beta2 !!!
```
cat <<EOF | sudo tee /etc/kubernetes/config/kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1beta2
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF

```



### Verification
??? Run the following commands from the same machine used to create the compute instances. ???

Run the command from the host that created the certificates?
Run the command from the host and dir where cert lives
* Make a HTTP request for the Kubernetes version info:


```
controller1 06:03:32 /var/lib/kubernetes{8} curl --cacert ca.pem https://10.10.1.51:6443/version
{
  "major": "1",
  "minor": "23",
  "gitVersion": "v1.23.3",
  "gitCommit": "816c97ab8cff8a1c72eccca1026f7820e93e0d25",
  "gitTreeState": "clean",
  "buildDate": "2022-01-25T21:19:12Z",
  "goVersion": "go1.17.6",
  "compiler": "gc",
  "platform": "linux/amd64"

```

























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









# load balancer

## install keepalive and HAproxy

## configure

```
cat > keepalived.conf <<EOF
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
  timeout 10
  fall 5
  rise 2
  weight -2
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 1
    priority 100
    advert_int 5
    authentication {
        auth_type PASS
        auth_pass mysecret
    }
    virtual_ipaddress {
        10.10.1.40/24
    }
    track_script {
        check_apiserver
    }
}
EOF

```


sudo vim check_apiserver.sh
chmod +x check_apiserver.sh
sudo mv check_apiserver.sh keepalived.conf


add to /etc/haproxy/haproxy.cfg
```
frontend kube-apiserver
  bind *:6443
  mode tcp
  option tcplog
  default_backend kube-apiserver

backend kube-apiserver
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  option ssl-hello-chk
  balance roundrobin
    server controller1 10.240.0.51:6443 check fall 3 rise 2
    server controller2 10.240.0.52:6443 check fall 3 rise 2
    server controller3 10.240.0.53:6443 check fall 3 rise 2
```

sudo systemctl daemon-reload




curl --cacert /var/lib/kubernetes/ca.pem https://10.10.1.40:6443/version
{
  "major": "1",
  "minor": "23",
  "gitVersion": "v1.23.4",
  "gitCommit": "e6c093d87ea4cbb530a7b2ae91e54c0842d8308a",
  "gitTreeState": "clean",
  "buildDate": "2022-02-16T12:32:02Z",
  "goVersion": "go1.17.7",
  "compiler": "gc",
  "platform": "linux/amd64"