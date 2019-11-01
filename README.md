# fiware-grimoirelab
Kubernetes deployment of the [GrimoireLab](https://github.com/chaoss/grimoirelab) solution with the FIWARE GEs.
For mor information about GrimoireLab, you can access to the documentation in [http://chaoss.github.io/grimoirelab](http://chaoss.github.io/grimoirelab).

## Configuration

There are 2 files that have to be considered to execute the solution with the FIWARE GEs:
* [credentials.cfg](./conf/credentials.cfg), this file has to contain the corresponding github token to access
to the different GitHub repositories and extract the information.
* [projects.json](./conf/projects.json), this file contains the complete list of FIWARE GEs GitHub links
to analize the content. 

## Execution

### Docker

To execute locally the GrimoireLab in a docker engine you need to download the docker image
with the following command:

```console
docker pull grimoirelab/full
```

When this operation is finished, you need to execute the docker image with the following 
command:

```console
docker run -p 127.0.0.1:5601:5601 -v $(pwd)/credentials.cfg:/override.cfg -v $(pwd)/projects.json:/projects.json -t grimoirelab/full
```

It will create the docker instance of the grimoirelab locally in the port 5601. You can open
your browser and go to the corresponding url http://127.0.0.1:5601

### Kubernetes

## create a namespace

```console
kubectl create -f namespace.yaml
```

view available namespaces for in your cluster:

```console
kubectl get namespaces
```

## create a service

```console
kubectl create -f service.yaml
```

view the service and its corresponding information:

```console
kubectl get services -n fiware-grimoirelab
```

## create the deployment

```console
kubectl create -f deployment.yaml
```

view deployment:

```console
kubectl get deployment fiware-grimoirelab -n fiware-grimoirelab
```

to deploy a new version:

```console
kubectl apply -f deployment.yaml
```

rollout the deployment:

```console
kubectl rollout undo deployment/fiware-grimoirelab --namespace fiware-grimoirelab
```

## License

FIWARE deployment of the Grimoirelab is licensed under APACHE License 2.0
