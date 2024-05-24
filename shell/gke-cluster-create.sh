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

# Echo variable assignments
echo ""
echo ""
echo "Current variable assignments:"
echo "" 
echo "region: $region"
echo "project: $project"
echo "cluster_name: $cluster_name"
echo "cluster_version: $cluster_version"
echo "release_channel: $release_channel"
echo "machine_type: $machine_type"
echo "image_type: $image_type"
echo "disk_type: $disk_type"
echo "disk_size: $disk_size"
echo "metadata: $metadata"
echo "scopes: $scopes"
echo "num_nodes: $num_nodes"
echo "logging: $logging"
echo "monitoring: $monitoring"
echo "network: $network"
echo "subnetwork: $subnetwork"
echo "default_max_pods_per_node: $default_max_pods_per_node"
echo "security_posture: $security_posture"
echo "workload_vulnerability_scanning: $workload_vulnerability_scanning"
echo "addons: $addons"
echo "enable_autoupgrade: $enable_autoupgrade"
echo "enable_autorepair: $enable_autorepair"
echo "max_surge_upgrade: $max_surge_upgrade"
echo "max_unavailable_upgrade: $max_unavailable_upgrade"
echo "binauthz_evaluation_mode: $binauthz_evaluation_mode"
echo "enable_managed_prometheus: $enable_managed_prometheus"
echo "enable_shielded_nodes: $enable_shielded_nodes"
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
