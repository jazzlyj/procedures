# PreReqs 
* disable swap
https://github.com/jazzlyj/notes/blob/master/ubuntu20.md#disable-swap


# MAAS/Juju/K8s Install
* Customize install, the bundle.yaml file
    * set the number of hosts and the MAAS tags in the constraints.
    * set the machine number in the to: block of each charm; the machine to deploy it to.

* install the charm bundle
https://ubuntu.com/kubernetes/docs/install-manual

```
juju deploy ./k8sBundle.yaml
```


NOTES: 
1. Do not run a load balancer on the same host as a master or a worker. 
tried to set options to use prot 8443.
since it by default uses 6443 and the conflicts with the master or worker setup



2. Apache runs on port 80 so it cant run on a node like a worker that exposes port 80