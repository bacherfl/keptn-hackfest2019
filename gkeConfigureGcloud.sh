#!/bin/bash

clear
RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')
CLUSTER_NAME="$RESOURCE_PREFIX"-keptn-orders-cluster
GKE_CLUSTER_ZONE=$(cat creds.json | jq -r '.gkeClusterZone')
GKE_CLUSTER_REGION=$(cat creds.json | jq -r '.gkeClusterRegion')
GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')

echo "Run these commands on your laptop to configure gcloud and configure kubectl"
echo ""
echo "gcloud --quiet config set project $GKE_PROJECT"
echo "gcloud --quiet config set container/cluster $CLUSTER_NAME"
echo "gcloud --quiet config set compute/zone $GKE_CLUSTER_ZONE"
echo "gcloud container clusters get-credentials $CLUSTER_NAME --zone $GKE_CLUSTER_ZONE --project $GKE_PROJECT"
echo ""
echo "Would you like me to run them now?"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

gcloud --quiet config set project $GKE_PROJECT
gcloud --quiet config set container/cluster $CLUSTER_NAME
gcloud --quiet config set compute/zone $GKE_CLUSTER_ZONE
gcloud container clusters get-credentials $CLUSTER_NAME --zone $GKE_CLUSTER_ZONE --project $GKE_PROJECT

