
# create an image of a vm 
```
gcloud beta compute machine-images create controller-0 --project=k8s-hardway-new --source-instance=controller-0 --source-instance-zone=us-west1-c --storage-location=us-west1
```

```
gcloud beta compute machine-images create controller-1 --project=k8s-hardway-new --source-instance=controller-1 --source-instance-zone=us-west1-c --storage-location=us-west1

gcloud beta compute machine-images create controller-2 --project=k8s-hardway-new --source-instance=controller-2 --source-instance-zone=us-west1-c --storage-location=us-west1

gcloud beta compute machine-images create worker-0 --project=k8s-hardway-new --source-instance=worker-0 --source-instance-zone=us-west1-c --storage-location=us-west1

gcloud beta compute machine-images create worker-1 --project=k8s-hardway-new --source-instance=worker-1 --source-instance-zone=us-west1-c --storage-location=us-west1

gcloud beta compute machine-images create worker-2 --project=k8s-hardway-new --source-instance=worker-2 --source-instance-zone=us-west1-c --storage-location=us-west1
```