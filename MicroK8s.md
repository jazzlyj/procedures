# kubernetes

## Install MicroK8s
```
sudo snap install --classic microk8s
```

* Wait for MicroK8s to be ready
```
sudo microk8s status --wait-ready
```

*  Enable features required by Juju controller & charm
```
sudo microk8s enable storage dns ingress
```

* (Optional) Alias kubectl bundled with MicroK8s package
```
sudo snap alias microk8s.kubectl kubectl
```
* (Optional) Add current user to 'microk8s' group.
 This avoid needing to use 'sudo' with the 'microk8s' command

```
sudo usermod -aG microk8s
```
 (whoami)

* Activate the new group (in the current shell only). 
Log out and log back in to make the change system-wide
```
newgrp microk8s
```

## Install Charmcraft
```
sudo snap install charmcraft
```

## Install juju
```
sudo snap install --classic juju
```

* Bootstrap the Juju controller on MicroK8s
```
juju bootstrap microk8s micro
```
* Add a new model to Juju
```
juju add-model development
```



https://microk8s.io/docs/getting-started

```
microk8s kubectl get nodes
```

NAME   STATUS   ROLES    AGE   VERSION
hostname     Ready    <none>   31h   v1.22.4-3+adc4115d990346

```
microk8s kubectl get pods
```
No resources found in default namespace.

```
microk8s enable dns storage
```  

```  
Enabling DNS
Applying manifest
serviceaccount/coredns created
configmap/coredns created
Warning: spec.template.metadata.annotations[scheduler.alpha.kubernetes.io/critical-pod]: non-functional in v1.16+; use the "priorityClassName" field instead
deployment.apps/coredns created
service/kube-dns created
clusterrole.rbac.authorization.k8s.io/coredns created
clusterrolebinding.rbac.authorization.k8s.io/coredns created
Restarting kubelet
[sudo] password for : 
DNS is enabled
Enabling default storage class
deployment.apps/hostpath-provisioner created
storageclass.storage.k8s.io/microk8s-hostpath created
serviceaccount/microk8s-hostpath created
clusterrole.rbac.authorization.k8s.io/microk8s-hostpath created
clusterrolebinding.rbac.authorization.k8s.io/microk8s-hostpath created
Storage will be available soon
```
  
## other add ons 
```
microk8s enable helm3
```

```  
Enabling Helm 3
Fetching helm version v3.5.0.
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11.7M  100 11.7M    0     0  7756k      0  0:00:01  0:00:01 --:--:-- 7751k
Helm 3 is enabled
```


```  
If RBAC is not enabled access the dashboard using the default token retrieved with:

token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
microk8s kubectl -n kube-system describe secret $token

In an RBAC enabled setup (microk8s enable RBAC) you need to create a user with restricted
permissions as shown in:
https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md  
```  
  
  
## helm
* stand alone install
```
sudo snap install helm --classic
```


## kompose
