#!/bin/bash

RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')
CLUSTER_NAME="$RESOURCE_PREFIX"-keptn-orders-cluster
CLUSTER_ZONE=$(cat creds.json | jq -r '.gkeClusterZone')
CLUSTER_REGION=$(cat creds.json | jq -r '.gkeClusterRegion')
GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')
GKE_CLUSTER_VERSION=1.12.8-gke.10

echo "===================================================="
echo "About to provision Google Resources. "
echo "The provisioning will take several minutes"
echo "Google Project       : $GKE_PROJECT"
echo "Cluster Name         : $CLUSTER_NAME"
echo "Cluster Zone         : $CLUSTER_ZONE"
echo "Cluster Region       : $CLUSTER_REGION"
echo "Cluster Version      : $GKE_CLUSTER_VERSION"
echo "===================================================="
if ! [ "$1" == "skip" ]; then
  read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
fi
echo ""

echo "Configuring the project settings"
gcloud --quiet config set project $GKE_PROJECT
gcloud --quiet config set container/cluster $CLUSTER_NAME
gcloud --quiet config set compute/zone $CLUSTER_ZONE
echo ""

echo "enable the kubernetes api for the project"
# https://cloud.google.com/endpoints/docs/openapi/enable-api
# gcloud services list --available
gcloud services enable container.googleapis.com
echo ""

echo "provision the cluster"
# https://cloud.google.com/kubernetes-engine/docs/how-to/protecting-cluster-metadata#disable-legacy-apis
gcloud beta container \
  --project $GKE_PROJECT clusters create $CLUSTER_NAME \
  --zone $CLUSTER_ZONE \
  --no-enable-basic-auth \
  --cluster-version $GKE_CLUSTER_VERSION \
  --node-labels=owner=$CLUSTER_NAME \
  --machine-type "n1-standard-16" \
  --image-type "UBUNTU" \
  --disk-type "pd-standard" \
  --disk-size "100" \
  --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
  --num-nodes "1" \
  --enable-cloud-logging \
  --enable-cloud-monitoring \
  --no-enable-ip-alias \
  --network "projects/$PROJECT/global/networks/default" \
  --subnetwork "projects/$PROJECT/regions/$REGION/subnetworks/default" \
  --addons HorizontalPodAutoscaling,HttpLoadBalancing \
  --no-enable-autoupgrade

if [[ $? != 0 ]]; then
  echo ""
  echo "Error with 'gcloud container clusters create'"
  exit 1
fi

echo "get the credentials to the cluster"
gcloud container clusters get-credentials $CLUSTER_NAME \
            --zone $CLUSTER_ZONE \
            --project $GKE_PROJECT

if [[ $? != 0 ]]; then
  echo "Error with 'gcloud container clusters get-credentials'"
  exit 1
fi
