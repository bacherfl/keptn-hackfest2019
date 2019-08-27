#!/bin/bash

RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')
CLUSTER_NAME="$RESOURCE_PREFIX"-keptn-orders-cluster
CLUSTER_REGION=$(cat creds.json | jq -r '.eksClusterRegion')

echo "===================================================="
echo "About to provision AWS Resources. "
echo "The provisioning will take several minutes"
echo "Cluster Name         : $CLUSTER_NAME"
echo "Cluster Region       : $CLUSTER_REGION"
echo "===================================================="
if ! [ "$1" == "skip" ]; then
  read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
fi
echo ""

echo "------------------------------------------------------"
echo "Creating EKS Cluster: $CLUSTER_NAME"
echo "------------------------------------------------------"
eksctl create cluster --name=$CLUSTER_NAME --node-type=m5.2xlarge --nodes=1 --region=$CLUSTER_REGION  --version=1.13
eksctl utils update-coredns --name=$CLUSTER_NAME --region=$CLUSTER_REGION --approve

echo "------------------------------------------------------"
echo "Getting Cluster Credentials"
echo "------------------------------------------------------"
eksctl utils write-kubeconfig --name=$CLUSTER_NAME --region=$CLUSTER_REGION --set-kubeconfig-context
