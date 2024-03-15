#!/usr/bin/env bash

read -s -p "Enter Password for sudo: " sudoPW
echo $sudoPW | sudo snap install helm --classic

alias k=kubectl

# Install helm chart
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

# Validate
kubectl --namespace monitoring get pods -l "release=kube-prometheus-stack" -owide

# Intentional delay
echo "Waiting 30 seconds for pods to be ready for port-forwarding..."
sleep 30
echo "Finished waiting."

# Forward service ports
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring &
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring &
