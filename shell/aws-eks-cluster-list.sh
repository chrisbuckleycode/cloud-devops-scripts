#!/bin/bash
##
## FILE: aws-eks-cluster-list.sh
##
## DESCRIPTION: For an AWS account, returns EKS clusters, their instances, types and lifecycle.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: aws-eks-cluster-list.sh <aws_profile>
##

# Get AWS profile from first argument
aws_profile=$1

aws_region="us-east-1"

# Get all EKS clusters in the account (profile)
clusters=$(aws eks list-clusters --profile $aws_profile --region $aws_region --output text --query 'clusters[*]')

# Loop through each cluster
for cluster in $clusters; do
  # Get all instances in the cluster (using cluster name tag)
  instances=$(aws ec2 describe-instances --filters "Name=tag:aws:eks:cluster-name,Values=$cluster" --profile $aws_profile --region $aws_region --query 'Reservations[*].Instances[*].[InstanceId]' --output text)
  
  # Loop through each instance
  for instance in $instances; do
    instance_type=$(aws ec2 describe-instances --instance-ids $instance --profile $aws_profile --region $aws_region --output text --query 'Reservations[0].Instances[0].InstanceType')
    instance_lifecycle=$(aws ec2 describe-instances --instance-ids $instance --profile $aws_profile --region $aws_region --output text --query 'Reservations[*].Instances[*].[InstanceLifecycle]')

    echo "$cluster, $instance, $instance_type, $instance_lifecycle"
  done

done
