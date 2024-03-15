# Bootstrap Sandbox Environment with Kube-Prometheus-Stack

## Summary
- Quickly install with default settings the Kube-Prometheus-Stack: "a collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator."
- Only for sandbox environments. Use ArgoCD for Prod/Stage/NonProd/Dev.
- Tested successfully on ACloudGuru example lab environment.

## Usage
- 1.remote-kube-prometheus-stack-bootstrap.sh - Run on remote (bastion/jumpbox) to install helm chart and forward ports to Prometheus and Grafana.
- 2.local-ssh-tunnel.sh - Run on local laptop to create a tunnel from your laptop's ports to the remote bastion's forwarded ports.
- 9.remote-kube-prometheus-stack-decomm.sh - Run on remote (bastion/jumpbox) to tear down/decommission.

## Links
- https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
- https://learn.acloud.guru/handson/04f75c85-5623-4741-9f40-dcfd836c8482
- http://localhost:3000 (admin:prom-operator)
- http://localhost:9090
