#!/bin/bash
##
## FILE: 1.remote-kube-prometheus-stack-bootstrap.sh
##
## DESCRIPTION: Installs Helm chart, kube-prometheus-stack and forwards service ports.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: 1.remote-kube-prometheus-stack-bootstrap.sh
##

read -s -p "Enter Password for sudo: " sudoPW
echo $sudoPW | sudo snap install helm --classic

alias k=kubectl

# Install helm chart
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

# Validate
kubectl --namespace monitoring get pods -l "release=kube-prometheus-stack" -owide

# Wait for condition ready pods prior to port-forwarding
kubectl wait --timeout=120s --namespace=monitoring --for=condition=Ready pods --all

# Forward service ports
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring &
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring &
