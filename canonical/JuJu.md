# JuJu Install and Setup
https://docs.openstack.org/project-deploy-guide/charm-deployment-guide/latest/install-juju.html


### Install
* snap install juju
```
sudo snap install juju --classic
```

### Add MAAS to Juju
* create juju "maas-cloud.yaml"
```
vim maas-cloud.yaml

# add this content:
clouds:
  mymaas:
    type: maas
    auth-types: [oauth1]
    endpoint: http://$IPADDR:5240/MAAS

```

* Add the cloud
```
juju add-cloud --client -f maas-cloud.yaml mymaas

# stdout:
Since Juju 2 is being run for the first time, downloaded the latest public cloud information.
Cloud "mymaas" successfully added to your local client.
You will need to add a credential for this cloud (`juju add-credential mymaas`)
before you can use it to bootstrap a controller (`juju bootstrap mymaas`) or
to create a model (`juju add-model <your model name> mymaas`).
```


* update a cloud
```
juju update-cloud mymaas --client -f maas-cloud.yaml

# std out:
Cloud "mymaas" updated on this client using provided file.
```


### Add MAAS Credentials 
```
vim maas-creds.yaml

# add this content and change the admin api key to the one generated during maas setup
credentials:
  mymaas:
    anyuser:
      auth-type: oauth1
      maas-oauth: $MASSAPIKEY
```

* add credential
```
juju add-credential --client -f maas-creds.yaml mymaas

# std out:
Credential "anyuser" added locally for cloud "mymaas".
```

* View list of credentials 
```
juju credentials --client --show-secrets --format yaml
```

### Create the Juju controller 
* The MAAS web UI will show the node being deployed. 
* NOTE: if the node has Manual Power management, you will need to reboot the node to begin the deployment.

```
juju bootstrap --bootstrap-series=focal --constraints tags=juju mymaas maas-controller

# std out:
Creating Juju controller "maas-controller" on mymaas/default
Looking for packaged Juju agent version 2.9.22 for amd64
Located Juju agent version 2.9.22-ubuntu-amd64 at https://streams.canonical.com/juju/tools/agent/2.9.22/juju-2.9.22-ubuntu-amd64.tgz
Launching controller instance(s) on mymaas/default...
 - pnb6ce (arch=amd64 mem=15.8G cores=8)
Installing Juju agent on bootstrap instance
Fetching Juju Dashboard 0.8.1
Waiting for address
Attempting to connect to 10.10.1.5:22
Connected to 10.10.1.5
Running machine configuration script...
Bootstrap agent now started
Contacting Juju controller at 10.10.1.5 to verify accessibility...

Bootstrap complete, controller "maas-controller" is now available
Controller machines are in the "controller" model
Initial model "default" added
```

* View list of controllers
``` 
juju controllers
```

* destroy a controller and the all that goes with it
```
juju destroy-controller maas-controller -y --destroy-all-models --destroy-storage
```

### Create the Model
* create the model 
```
juju add-model --config default-series=focal openstack

# std out:
Added 'openstack' model on mymaas/default with credential 'anyuser' for user 'admin'

```

* get status
```
juju status

# std out:
Model      Controller       Cloud/Region    Version  SLA          Timestamp
openstack  maas-controller  mymaas/default  2.9.22   unsupported  14:09:25-08:00

Model "admin/openstack" is empty.

```