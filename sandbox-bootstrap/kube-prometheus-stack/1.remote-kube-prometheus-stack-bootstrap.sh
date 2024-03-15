#!/usr/bin/env bash

read -s -p "Enter Password for sudo: " sudoPW
echo $sudoPW | sudo snap install helm --classic
alias k=kubectl
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
kubectl --namespace monitoring get pods -l "release=kube-prometheus-stack" -owide
echo "Waiting 10 seconds for pods to be ready for port-forwarding..."
sleep 10
echo "Finished waiting."
kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring &
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring &
