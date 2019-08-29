#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

if ! [ "$2" == "skip" ]; then  
  clear
fi
echo "-------------------------------------------------------"
echo -n "Validating keptn CLI installed. "
type keptn &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error"
    echo ">>> Missing 'keptn' CLI utility"
    echo ""
    exit 1
fi
echo ""
echo "OK, found: $(command -v keptn)"
echo "$(keptn version)"
echo "-------------------------------------------------------"
echo ""

KEPTN_BRANCH=$(cat creds.json | jq -r '.keptnBranch')

echo "========================================================="
echo "About to install Keptn using branch: $KEPTN_BRANCH"
echo "and to prepare credential files for Keptn installation."
if ! [ "$2" == "skip" ]; then  
  read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
fi
echo ""

# get values needed for file
SOURCE_CREDS_FILE=creds.json
GITHUB_PERSONAL_ACCESS_TOKEN=$(cat $SOURCE_CREDS_FILE | jq -r '.githubPersonalAccessToken')
GITHUB_USER_NAME=$(cat $SOURCE_CREDS_FILE | jq -r '.githubUserName')
GITHUB_USER_EMAIL=$(cat $SOURCE_CREDS_FILE | jq -r '.githubUserEmail')
GITHUB_ORGANIZATION=$(cat $SOURCE_CREDS_FILE | jq -r '.githubOrg')
RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')
CLUSTER_NAME="$RESOURCE_PREFIX"-keptn-orders-cluster

# GKE
GKE_PROJECT=$(cat $SOURCE_CREDS_FILE | jq -r '.gkeProject')
GKE_CLUSTER_ZONE=$(cat $SOURCE_CREDS_FILE | jq -r '.gkeClusterZone')
GKE_CLUSTER_REGION=$(cat $SOURCE_CREDS_FILE | jq -r '.gkeClusterRegion')
# AKS
AKS_RESOURCEGROUP="$RESOURCE_PREFIX"-keptn-orders-group
AKS_SUBSCRIPTION_ID=$(cat $SOURCE_CREDS_FILE | jq -r '.aksSubscriptionId')
# EKS
EKS_CLUSTER_REGION=$(cat $SOURCE_CREDS_FILE | jq -r '.eksClusterRegion')

echo "-------------------------------------------------------"
echo "Cloning Keptn installer repo and building credential file"

KEPTN_GIT_REPO=https://github.com/keptn/installer
echo -e "Cloning $KEPTN_GIT_REPO branch $KEPTN_BRANCH"
rm -rf installer
git clone --branch $KEPTN_BRANCH $KEPTN_GIT_REPO --single-branch

echo "-------------------------------------------------------"
echo "Creating Keptn credential files"

# copy the values we already captured 
# and use them to create the creds.json file and the creds_dt.json
# files that the installers expect
case $DEPLOYMENT in
  aks)
    cd installer/scripts/aks
    KEPTN_CREDS_FILE=creds.json
    KEPTN_CREDS_SAVE_FILE=creds.sav
    rm $KEPTN_CREDS_FILE 2> /dev/null

    cat $KEPTN_CREDS_SAVE_FILE | \
      sed 's~GITHUB_USER_NAME_PLACEHOLDER~'"$GITHUB_USER_NAME"'~' | \
      sed 's~PERSONAL_ACCESS_TOKEN_PLACEHOLDER~'"$GITHUB_PERSONAL_ACCESS_TOKEN"'~' | \
      sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
      sed 's~GITHUB_ORG_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' | \
      sed 's~CLUSTER_NAME_PLACEHOLDER~'"$CLUSTER_NAME"'~' | \
      sed 's~AZURE_SUBSCRIPTION~'"$AKS_SUBSCRIPTION_ID"'~' | \
      sed 's~AZURE_RESOURCE_GROUP~'"$AKS_RESOURCEGROUP"'~' >> $KEPTN_CREDS_FILE
    ;;
  gke)
    cd installer/scripts/gke
    KEPTN_CREDS_FILE=creds.json
    KEPTN_CREDS_SAVE_FILE=creds.sav
    rm $KEPTN_CREDS_FILE 2> /dev/null

    cat $KEPTN_CREDS_SAVE_FILE | \
      sed 's~GITHUB_USER_NAME_PLACEHOLDER~'"$GITHUB_USER_NAME"'~' | \
      sed 's~PERSONAL_ACCESS_TOKEN_PLACEHOLDER~'"$GITHUB_PERSONAL_ACCESS_TOKEN"'~' | \
      sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
      sed 's~GITHUB_ORG_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' | \
      sed 's~CLUSTER_NAME_PLACEHOLDER~'"$CLUSTER_NAME"'~' | \
      sed 's~CLUSTER_ZONE_PLACEHOLDER~'"$GKE_CLUSTER_ZONE"'~' | \
      sed 's~GKE_PROJECT_PLACEHOLDER~'"$GKE_PROJECT"'~' >> $KEPTN_CREDS_FILE
    ;;
  eks)
    cd installer/scripts/gke
    KEPTN_CREDS_FILE=creds.json
    KEPTN_CREDS_SAVE_FILE=creds.sav
    rm $KEPTN_CREDS_FILE 2> /dev/null

    cat $KEPTN_CREDS_SAVE_FILE | \
      sed 's~GITHUB_USER_NAME_PLACEHOLDER~'"$GITHUB_USER_NAME"'~' | \
      sed 's~PERSONAL_ACCESS_TOKEN_PLACEHOLDER~'"$GITHUB_PERSONAL_ACCESS_TOKEN"'~' | \
      sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
      sed 's~GITHUB_ORG_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' | \
      sed 's~CLUSTER_NAME_PLACEHOLDER~'"$CLUSTER_NAME"'~' | \
      sed 's~CLUSTER_ZONE_PLACEHOLDER~'"$EKS_CLUSTER_REGION"'~' >> $KEPTN_CREDS_FILE

      # TODO update once CLI updated
      # sed 's~CLUSTER_REGION_PLACEHOLDER~'"$EKS_CLUSTER_REGION"'~' >> $KEPTN_CREDS_FILE
    ;;
  *)
    echo "Skipping keptn install. $DEPLOYMENT_NAME not supported"
    exit
esac

echo ""
echo "======================================================="
echo About to install Keptn with these parameters:
echo ""
echo "cat creds.json"
cat creds.json
echo ""
echo "======================================================="
if ! [ "$2" == "skip" ]; then  
  read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
fi
echo ""

echo "-------------------------------------------------------"
echo "Running keptn install  This will take several minutes"
echo "-------------------------------------------------------"
START_TIME=$(date)

case $DEPLOYMENT in
  gke)
    keptn install -c=creds.json --platform=gke
    ;;
  aks)
    keptn install -c=creds.json --platform=aks
    ;;
  eks)
    # TODO update once CLI updated
    keptn install -c=creds.json --platform=eks --keptn-version=develop --verbose
    ;;
esac

cd ../../..

echo "-------------------------------------------------------"
echo "Finished Running keptn install"
echo "-------------------------------------------------------"
echo "Script start time : $START_TIME"
echo "Script end time   : "$(date)

echo "-------------------------------------------------------"
# show Keptn
./showKeptn.sh

case $DEPLOYMENT in 
  eks)
    # TODO remove once CLI updated
    EKS_DOMAIN=$(cat creds.json | jq -r '.eksDomain')
    GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
    GITHUB_USER_NAME=$(cat creds.json | jq -r '.githubUserName')
    GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')

    echo "Updating the domain..."
    keptn configure domain $EKS_DOMAIN --keptn-version=develop

    echo "Updating the Keptn GitHub organization..."
    keptn configure --org=$GITHUB_ORGANIZATION --user=$GITHUB_USER_NAME --token=$GITHUB_PERSONAL_ACCESS_TOKEN
    ;;
esac