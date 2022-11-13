# Pods and Container Introspection Commands


Lists all current pods

```bash
kubectl get pods
```


Describes pod names

```bash
kubectl describe pod<name>
```


Lists all replication controllers

```bash
kubectl get rc
```


Lists replication controllers in a namespace

```bash
kubectl get rc –namespace=”namespace”
```


Shows the replication controller name

```bash
kubectl describe rc <name>
```


Lists services

```bash
kubectl get svc
```


Shows a service name

```bash
kubectl describe svc<name>
```


Deletes a pod

```bash
kubectl delete pod<name>
```



Watches nodes continuously

```bash
kubectl get nodes -w
```



# Debugging Commands

Executes the command on service by choosing a container

```bash
kubectl exec<service><commands>[-c< $container>]
```


Gets logs from the service for a container
```bash
kubectl logs -f<name>>[-c< $container>]
```


Shows metrics for a node
```bash
kubectl top node
```


Shows metrics for a pod
```bash
kubectl top pod
```


 

 

# Cluster Introspection Commands

To get version-related information
```bash
kubectl version
```


To get cluster-related information
```bash
kubectl cluster-info

```

To get configuration details
```bash
kubectl config g view
```

```bash

```
To get information about a node
```bash
kubectl describe node<node>
```




# Quick Commands

Launching a pod with a name and image.
```bash
kubectl run<name> — image=<image-name>
```


To create a service detailed in <manifest.yaml>
```bash
kubectl create -f <manifest.yaml>
```


To scale the replication counter, counting the number of instances.
```bash
kubectl scale –replicas=<count>rc<name>
```

Mapping the external port to the internal replication port.
```bash
Expose rc<name> –port=<external>–target-port=<internal>
```


Stopping all pods in <n>
```bash
kubectl drain<n>– delete-local-data–force–ignore-daemonset
```


To create a namespace.
```bash
kubectl create namespace <namespace>
```


To let the master node run pods.
```bash
kubectltaintnodes –all-node-role.kuernetes.io/master-
```
