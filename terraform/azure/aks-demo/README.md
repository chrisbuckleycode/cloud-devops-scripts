# Azure Kubernetes Service (AKS) Demo

A simple example of Azure kubernetes Service (AKS). Unlike AWS' EKS, there is no prerequisite for tedious networking configuration for a simple starting cluster.

## Authentication

e.g.

```
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

## Deployment

```
terraform init
terraform plan out=planfile
terraform apply planfile

```

## Validation

```
terraform output -raw client_certificate
terraform output -raw kube_config
terraform output -raw client_key
terraform output -raw cluster_ca_certificate
terraform output -raw host
terraform output -raw username
terraform output -raw password
```

```
kubectl config current-context
kubectl config get-contexts
kubectl config use-context <cluster-name>
```

```
kubectl get ns | grep namespace-01
kubectl get all -n nginx
pod=$(kubectl get pods -A|grep nginx|awk '{print $2}' | head -1) | kubectl get pod $pod -n nginx -o json | jq '.items[].status'

kubectl get rs -A
replicaset=$(kubectl get rs -A | grep nginx | awk '{print $2}') | kubectl delete rs $replicaset -n nginx

kubectl get services -n nginx
or
read ip < <(pod=$(kubectl get pods -A|grep nginx|awk '{print $2}' | head -1) | kubectl get pod $pod -n nginx -o json | jq  -r '.items[0].status.hostIP')
echo "${ip}:30201"
```
Curl the above

## Future Improvements
- Finalize curl command and check why no output obtained
- Infrastructure security
- Deploy applications
- Separate infra and application config, reference data resources from one to the other

## Resources

[Best practices for running Kubernetes on Azure](https://github.com/Azure/k8s-best-practices)
[Using Kubectl to Restart a Kubernetes Pod](https://www.containiq.com/post/using-kubectl-to-restart-a-kubernetes-pod)
