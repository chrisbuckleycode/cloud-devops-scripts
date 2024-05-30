#!/usr/bin/env bash

# Creates a GKE test cluster, default 3 nodes.
# Requires gcloud (authenticated) and kubectl or simply run it from GCP Cloud Shell.

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variable configurations
region="us-central1"
project=$(gcloud config get-value project 2> /dev/null | sed -n '1p')
cluster_name="test-cluster"
cluster_version="1.28.8-gke.1095000"
release_channel="regular"
machine_type="e2-medium"    # shared 2vcpu 4gb ram
image_type="COS_CONTAINERD"
disk_type="pd-balanced"
disk_size="100"
metadata="disable-legacy-endpoints=true"
scopes="https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append"
num_nodes="1"
logging="SYSTEM,WORKLOAD"
monitoring="SYSTEM"
network="projects/"$project"/global/networks/default"
subnetwork="projects/"$project"/regions/"$region"/subnetworks/default"
default_max_pods_per_node="110"
security_posture="standard"
workload_vulnerability_scanning="disabled"
addons="HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver"
enable_autoupgrade=true
enable_autorepair=true
max_surge_upgrade=1
max_unavailable_upgrade=0
binauthz_evaluation_mode="DISABLED"
enable_managed_prometheus=true
enable_shielded_nodes=true
node_locations="${region}-a,${region}-b,${region}-c"

# Echo main variable assignments
echo ""
echo ""
echo "Main variable assignments:"
echo "" 
echo "region: $region"
echo "cluster_name: $cluster_name"
echo "num_nodes: $num_nodes"
echo "node_locations: $node_locations"
echo ""
echo -e "${YELLOW}Ready to create Kubernetes cluster?${NC}"
# Prompt user to continue
read -p "Press Enter to continue..."

# Enable GCP Kubernetes API
gcloud services enable container.googleapis.com

# Run the gcloud command with the variable configurations
gcloud beta container --project "$project" clusters create "$cluster_name" \
  --region "$region" \
  --no-enable-basic-auth \
  --cluster-version "$cluster_version" \
  --release-channel "$release_channel" \
  --machine-type "$machine_type" \
  --image-type "$image_type" \
  --disk-type "$disk_type" \
  --disk-size "$disk_size" \
  --metadata "$metadata" \
  --scopes "$scopes" \
  --num-nodes "$num_nodes" \
  --logging="$logging" \
  --monitoring="$monitoring" \
  --enable-ip-alias \
  --network "$network" \
  --subnetwork "$subnetwork" \
  --no-enable-intra-node-visibility \
  --default-max-pods-per-node "$default_max_pods_per_node" \
  --security-posture="$security_posture" \
  --workload-vulnerability-scanning="$workload_vulnerability_scanning" \
  --no-enable-master-authorized-networks \
  --addons "$addons" \
  $(if [[ "$enable_autoupgrade" = true ]]; then echo "--enable-autoupgrade"; fi) \
  $(if [[ "$enable_autorepair" = true ]]; then echo "--enable-autorepair"; fi) \
  --max-surge-upgrade "$max_surge_upgrade" \
  --max-unavailable-upgrade "$max_unavailable_upgrade" \
  --binauthz-evaluation-mode="$binauthz_evaluation_mode" \
  $(if [[ "$enable_managed_prometheus" = true ]]; then echo "--enable-managed-prometheus"; fi) \
  $(if [[ "$enable_shielded_nodes" = true ]]; then echo "--enable-shielded-nodes"; fi) \
  --node-locations "$node_locations"

# Loop until the cluster status is "RUNNING"
status=""
while [[ "$status" != "RUNNING" ]]; do
    # Sleep for a few seconds before checking the status again
    sleep 5
    status=$(gcloud container clusters describe "$cluster_name" --region "$region" --project "$project" --format="value(status)")
done
echo -e "${YELLOW}Cluster is now running.${NC}"

# Generate kubeconfig
gcloud container clusters get-credentials "$cluster_name" --region="$region"

# Set the current-context
kubectl config use-context "gke_${project}_${region}_${cluster_name}"

# Grant current user the cluster-admin role
user_email=$(gcloud config list account --format "value(core.account)")
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user "$user_email"

# Add helm repos
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo -e "${YELLOW}Ready to install ingress-nginx?${NC}"
# Prompt user to continue
read -p "Press Enter to continue..."

namespace_ingress="ingress-nginx"

# Helm install ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
    --create-namespace \
    --namespace $namespace_ingress \
    --set controller.replicaCount=3 \

# Wait for LoadBalancer External IP to be assigned
ingress_external_ip=""
while [[ -z "$ingress_external_ip" ]]; do
    ingress_external_ip=$(kubectl get svc -A -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].status.loadBalancer.ingress[0].ip}')
    sleep 1
done

echo -e "${YELLOW}Ingress external IP is:${NC} ${GREEN}$ingress_external_ip ${NC}"

echo -e "${YELLOW}Ready to install cert-manager?${NC}"
# Prompt user to continue
read -p "Press Enter to continue..."


helm install cert-manager jetstack/cert-manager \
    --create-namespace \
    --namespace cert-manager \
    --set installCRDs=true

kubectl apply -f cert-manager.yaml

output_staging=$(kubectl describe clusterissuer letsencrypt-staging)
output_prod=$(kubectl describe clusterissuer letsencrypt-prod)

if [[ $output_staging =~ "The ACME account was registered with the ACME server" ]]; then
  echo "letsencrypt-staging: The ACME account was registered with the ACME server"
fi

if [[ $output_prod =~ "The ACME account was registered with the ACME server" ]]; then
  echo "letsencrypt-prod: The ACME account was registered with the ACME server"
fi


echo -e "${YELLOW}Ready to install kube-prometheus-stack?${NC}"
# Prompt user to continue
read -p "Press Enter to continue..."



helm install prometheus prometheus-community/kube-prometheus-stack \
    --create-namespace \
    --namespace prometheus



echo -e "${YELLOW}Ready to install whereami app?${NC}"
# Prompt user to continue
read -p "Press Enter to continue..."

# Update whereami app manifest
before="XXXXX"
sed -i "s/${before}/${ingress_external_ip}/g" whereami.yaml

# Install whereami app
kubectl apply -f whereami.yaml

# Wait for Ingress to activate
ingress_address=""
while [[ -z "$ingress_address" ]]; do
    ingress_address=$(kubectl get ingress -n whereami -o jsonpath='{.items[?(@.metadata.name=="'ingress-whereami'")].status.loadBalancer.ingress[*].ip}')
    sleep 1
done

echo -e "${YELLOW}whereami url is:${NC} ${GREEN}whereami.$ingress_external_ip.nip.io ${NC}"

curl whereami.$ingress_external_ip.nip.io







echo -e "${YELLOW}Ready to install kube-web-view app?${NC}"
# Prompt user to continue
read -p "Press Enter to continue..."

# Update kube-web-view app manifest
before="XXXXX"
sed -i "s/${before}/${ingress_external_ip}/g" kube-web-view.yaml

# Install kube-web-view app
kubectl apply -f kube-web-view.yaml

# Wait for Ingress to activate
ingress_address=""
while [[ -z "$ingress_address" ]]; do
    ingress_address=$(kubectl get ingress -n kube-web-view -o jsonpath='{.items[?(@.metadata.name=="'ingress-kube-web-view'")].status.loadBalancer.ingress[*].ip}')
    sleep 1
done

echo -e "${YELLOW}kube-web-view url is:${NC} ${GREEN}kube-web-view.$ingress_external_ip.nip.io ${NC}"

curl kube-web-view.$ingress_external_ip.nip.io





echo -e "${YELLOW}Ready to install whereamisecure app?${NC}"
# Prompt user to continue
read -p "Press Enter to continue..."

# Update whereamisecure app manifest
before="XXXXX"
sed -i "s/${before}/${ingress_external_ip}/g" whereamisecure.yaml

# Install whereamisecure app
kubectl apply -f whereamisecure.yaml

# Wait for Ingress to activate
ingress_address=""
while [[ -z "$ingress_address" ]]; do
    ingress_address=$(kubectl get ingress -n whereamisecure -o jsonpath='{.items[?(@.metadata.name=="'ingress-whereamisecure'")].status.loadBalancer.ingress[*].ip}')
    sleep 1
done

echo -e "${YELLOW}whereamisecure url is:${NC} ${GREEN}whereamisecure.$ingress_external_ip.nip.io ${NC}"

curl whereamisecure.$ingress_external_ip.nip.io

kubectl get certificate -n whereamisecure

kubectl -n whereamisecure describe certificate whereamisecure-tls

k describe secret whereamisecure-tls -n whereamisecure



