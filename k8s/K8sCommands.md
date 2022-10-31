# Pods and Container Introspection Commands


Lists all current pods

```bash
Kubectl get pods
```


Describes pod names

```bash
Kubectl describe pod<name>
```


Lists all replication controllers

```bash
Kubectl get rc
```


Lists replication controllers in a namespace

```bash
Kubectl get rc –namespace=”namespace”
```


Shows the replication controller name

```bash
Kubectl describe rc <name>
```


Lists services

```bash
Kubectl get svc
```


Shows a service name

```bash
Kubectl describe svc<name>
```


Deletes a pod

```bash
Kubectl delete pod<name>
```



Watches nodes continuously

```bash
Kubectl get nodes -w
```



# Debugging Commands

Executes the command on service by choosing a container

```bash
Kubectl exec<service><commands>[-c< $container>]
```


Gets logs from the service for a container
```bash
Kubectl logs -f<name>>[-c< $container>]
```


Shows metrics for a node
```bash
Kubectl top node
```


Shows metrics for a pod
```bash
Kubectl top pod
```


 

 

# Cluster Introspection Commands

To get version-related information
```bash
Kubectl version
```


To get cluster-related information
```bash
Kubectl cluster-info

```

To get configuration details
```bash
Kubectl config g view
```

```bash

```
To get information about a node
```bash
Kubectl describe node<node>
```




# Quick Commands

Launching a pod with a name and image.
```bash
Kubectl run<name> — image=<image-name>
```


To create a service detailed in <manifest.yaml>
```bash
Kubectl create -f <manifest.yaml>
```


To scale the replication counter, counting the number of instances.
```bash
Kubectl scale –replicas=<count>rc<name>
```

Mapping the external port to the internal replication port.
```bash
Expose rc<name> –port=<external>–target-port=<internal>
```


Stopping all pods in <n>
```bash
Kubectl drain<n>– delete-local-data–force–ignore-daemonset
```


To create a namespace.
```bash
Kubectl create namespace <namespace>
```


To let the master node run pods.
```bash
Kubectltaintnodes –all-node-role.kuernetes.io/master-
```
