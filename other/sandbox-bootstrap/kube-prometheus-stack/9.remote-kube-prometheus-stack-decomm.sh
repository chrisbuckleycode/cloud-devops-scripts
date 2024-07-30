#!/bin/bash
##
## FILE: 9.remote-kube-prometheus-stack-decomm.sh
##
## DESCRIPTION: Uninstalls Helm chart, kube-prometheus-stack and removes traces (CRDs, namespace).
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: 9.remote-kube-prometheus-stack-decomm.sh
##

# Kill any still forwarded ports
pkill -f port-forward

# Uninstall helm chart, delete leftover CRDs, delete namespace
helm uninstall kube-prometheus-stack --namespace monitoring
kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
kubectl delete crd alertmanagers.monitoring.coreos.com
kubectl delete crd podmonitors.monitoring.coreos.com
kubectl delete crd probes.monitoring.coreos.com
kubectl delete crd prometheusagents.monitoring.coreos.com
kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd scrapeconfigs.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com
kubectl delete crd thanosrulers.monitoring.coreos.com
kubectl delete ns monitoring
