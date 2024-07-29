# Python Logger Demo

## Build Instructions

- Create a repo at DockerHub and substitute below.
- Substitute your DockerHub username below.
- Create a PAT for authentication.

```
$ docker build -t <repo>/python-logger:v2 -f Dockerfile .
$ docker login -u <username> docker.io
$ docker push <repo>/python-logger:v2
```

## Kubernetes Deploy Instructions

- Replace 'repo' with your own repo name in `python-logger-rs.yaml`

```
# Apply manifest to create objects (namespace and replicaset)
$ kubectl apply -f python-logger-rs.yaml

# Watch pods till READY
$ kubectl get pods -n python-logger -w

# Follow logs from all containers
$ kubectl -n python-logger logs -f -l app=python-logger --all-containers=true
```
