# Docker vs Kubernetes

* Docker - when you want to deploy a single (network accessible) container
* Docker Compose - when you want to deploy multiple containers to a single host from within a single YAML file
* Docker swarm - when you want to deploy a cluster of docker nodes (multiple hosts) for a simple, scalable application
* Kubernetes - when you need to manage a large deployment of scalable, automated containers

# Docker Compose to Kubernetes
* kompose is a tool to help users familiar with docker-compose move to Kubernetes. It takes a Docker Compose file and translates it into Kubernetes resources.
  * https://kompose.io/
