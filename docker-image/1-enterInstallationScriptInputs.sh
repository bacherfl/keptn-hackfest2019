#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

CREDS=./creds.json

if [ -f "$CREDS" ]
then
    DEPLOYMENT=$(cat creds.json | jq -r '.deployment | select (.!=null)')
    if [ -z $DEPLOYMENT ]
    then 
      DEPLOYMENT=$1
    fi
    KEPTN_BRANCH=$(cat creds.json | jq -r '.keptnBranch')
    RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')
    DT_HOSTNAME=$(cat creds.json | jq -r '.dynatraceHostName')
    DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
    DT_PAAS_TOKEN=$(cat creds.json | jq -r '.dynatracePaaSToken')
    GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')
    GITHUB_USER_NAME=$(cat creds.json | jq -r '.githubUserName')
    GITHUB_USER_EMAIL=$(cat creds.json | jq -r '.githubUserEmail')
    GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')

    AKS_SUBSCRIPTION_ID=$(cat creds.json | jq -r '.aksSubscriptionId')
    AKS_LOCATION=$(cat creds.json | jq -r '.aksLocation')

    GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')
    GKE_CLUSTER_ZONE=$(cat creds.json | jq -r '.gkeClusterZone')
    GKE_CLUSTER_REGION=$(cat creds.json | jq -r '.gkeClusterRegion')

    EKS_CLUSTER_REGION=$(cat creds.json | jq -r '.eksClusterRegion')
    EKS_DOMAIN=$(cat creds.json | jq -r '.eksDomain')
fi

echo "==================================================================="
echo -e "Please enter the values for provider type: $DEPLOYMENT_NAME:"
echo "==================================================================="
echo "Dynatrace Host Name (e.g. abc12345.live.dynatrace.com)"
read -p "                                       (current: $DT_HOSTNAME) : " DT_HOSTNAME_NEW
read -p "Dynatrace API Token                    (current: $DT_API_TOKEN) : " DT_API_TOKEN_NEW
read -p "Dynatrace PaaS Token                   (current: $DT_PAAS_TOKEN) : " DT_PAAS_TOKEN_NEW
read -p "GitHub User Name                       (current: $GITHUB_USER_NAME) : " GITHUB_USER_NAME_NEW
read -p "GitHub Personal Access Token           (current: $GITHUB_PERSONAL_ACCESS_TOKEN) : " GITHUB_PERSONAL_ACCESS_TOKEN_NEW
read -p "GitHub User Email                      (current: $GITHUB_USER_EMAIL) : " GITHUB_USER_EMAIL_NEW
read -p "GitHub Organization                    (current: $GITHUB_ORGANIZATION) : " GITHUB_ORGANIZATION_NEW
read -p "PaaS Resource Prefix (e.g. lastname)   (current: $RESOURCE_PREFIX) : " RESOURCE_PREFIX_NEW

case $DEPLOYMENT in
  eks)
    read -p "AWS Cluster Region (eg.us-east-1)      (current: $EKS_CLUSTER_REGION) : " EKS_CLUSTER_REGION_NEW
    read -p "AWS Domain (eg.jahn.demo.keptn.sh      (current: $EKS_DOMAIN) : " EKS_DOMAIN_NEW
    ;;
  aks)
    read -p "Azure Subscription ID                  (current: $AKS_SUBSCRIPTION_ID) : " AKS_SUBSCRIPTION_ID_NEW
    read -p "Azure Location                         (current: $AKS_LOCATION) : " AKS_LOCATION_NEW
    ;;
  gke)
    read -p "Google Project                         (current: $GKE_PROJECT) : " GKE_PROJECT_NEW
    read -p "Google Cluster Zone (eg.us-east1-b)    (current: $GKE_CLUSTER_ZONE) : " GKE_CLUSTER_ZONE_NEW
    read -p "Google Cluster Region (eg.us-east1)    (current: $GKE_CLUSTER_REGION) : " GKE_CLUSTER_REGION_NEW
    ;;
  ocp)
    ;;
esac
echo "==================================================================="
echo ""
# set value to new input or default to current value
KEPTN_BRANCH=${KEPTN_BRANCH_NEW:-$KEPTN_BRANCH}
RESOURCE_PREFIX=${RESOURCE_PREFIX_NEW:-$RESOURCE_PREFIX}
DT_HOSTNAME=${DT_HOSTNAME_NEW:-$DT_HOSTNAME}
DT_API_TOKEN=${DT_API_TOKEN_NEW:-$DT_API_TOKEN}
DT_PAAS_TOKEN=${DT_PAAS_TOKEN_NEW:-$DT_PAAS_TOKEN}
GITHUB_USER_NAME=${GITHUB_USER_NAME_NEW:-$GITHUB_USER_NAME}
GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_PERSONAL_ACCESS_TOKEN_NEW:-$GITHUB_PERSONAL_ACCESS_TOKEN}
GITHUB_USER_EMAIL=${GITHUB_USER_EMAIL_NEW:-$GITHUB_USER_EMAIL}
GITHUB_ORGANIZATION=${GITHUB_ORGANIZATION_NEW:-$GITHUB_ORGANIZATION}
# eks specific
EKS_CLUSTER_REGION=${EKS_CLUSTER_REGION_NEW:-$EKS_CLUSTER_REGION}
EKS_DOMAIN=${EKS_DOMAIN_NEW:-$EKS_DOMAIN}
# aks specific
AKS_SUBSCRIPTION_ID=${AKS_SUBSCRIPTION_ID_NEW:-$AKS_SUBSCRIPTION_ID}
AKS_LOCATION=${AKS_LOCATION_NEW:-$AKS_LOCATION}
# gke specific
GKE_PROJECT=${GKE_PROJECT_NEW:-$GKE_PROJECT}
GKE_CLUSTER_ZONE=${GKE_CLUSTER_ZONE_NEW:-$GKE_CLUSTER_ZONE}
GKE_REGION_ZONE=${GKE_CLUSTER_REGION_NEW:-$GKE_REGION_ZONE}

echo -e "Please confirm all are correct:"
echo ""
echo "Dynatrace Host Name          : $DT_HOSTNAME"
echo "Dynatrace API Token          : $DT_API_TOKEN"
echo "Dynatrace PaaS Token         : $DT_PAAS_TOKEN"
echo "GitHub User Name             : $GITHUB_USER_NAME"
echo "GitHub Personal Access Token : $GITHUB_PERSONAL_ACCESS_TOKEN"
echo "GitHub User Email            : $GITHUB_USER_EMAIL"
echo "GitHub Organization          : $GITHUB_ORGANIZATION" 
echo "PaaS Resource Prefix         : $RESOURCE_PREFIX"

case $DEPLOYMENT in
  eks)
    echo "AWS Cluster Region           : $EKS_CLUSTER_REGION"
    echo "AWS Domain                   : $EKS_DOMAIN"
    ;;
  aks)
    echo "Azure Subscription ID        : $AKS_SUBSCRIPTION_ID"
    echo "Azure Location               : $AKS_LOCATION"
    ;;
  gke)
    echo "Google Project               : $GKE_PROJECT"
    echo "Google Cluster Zone          : $GKE_CLUSTER_ZONE"
    echo "Google Cluster Region        : $GKE_CLUSTER_REGION"
    ;;
  ocp)
    ;;
esac
echo "==================================================================="
read -p "Is this all correct? (y/n) : " -n 1 -r
echo ""
echo "==================================================================="

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Making a backup $CREDS to $CREDS.bak"
    cp $CREDS $CREDS.bak 2> /dev/null
    rm $CREDS 2> /dev/null

    cat ./creds.sav | \
      sed 's~DEPLOYMENT_PLACEHOLDER~'"$DEPLOYMENT"'~' | \
      sed 's~KEPTN_BRANCH_PLACEHOLDER~'"$KEPTN_BRANCH"'~' | \
      sed 's~DYNATRACE_HOSTNAME_PLACEHOLDER~'"$DT_HOSTNAME"'~' | \
      sed 's~DYNATRACE_API_TOKEN_PLACEHOLDER~'"$DT_API_TOKEN"'~' | \
      sed 's~DYNATRACE_PAAS_TOKEN_PLACEHOLDER~'"$DT_PAAS_TOKEN"'~' | \
      sed 's~GITHUB_USER_NAME_PLACEHOLDER~'"$GITHUB_USER_NAME"'~' | \
      sed 's~PERSONAL_ACCESS_TOKEN_PLACEHOLDER~'"$GITHUB_PERSONAL_ACCESS_TOKEN"'~' | \
      sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
      sed 's~GITHUB_ORG_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' | \
      sed 's~RESOURCE_PREFIX_PLACEHOLDER~'"$RESOURCE_PREFIX"'~' > $CREDS

    case $DEPLOYMENT in
      eks)
        cp $CREDS $CREDS.temp
        cat $CREDS.temp | \
          sed 's~EKS_DOMAIN_PLACEHOLDER~'"$EKS_DOMAIN"'~' | \
          sed 's~EKS_CLUSTER_REGION_PLACEHOLDER~'"$EKS_CLUSTER_REGION"'~' > $CREDS
        rm $CREDS.temp 2> /dev/null
        ;;
      aks)
        cp $CREDS $CREDS.temp
        cat $CREDS.temp | \
          sed 's~AKS_SUBSCRIPTION_ID_PLACEHOLDER~'"$AKS_SUBSCRIPTION_ID"'~' | \
          sed 's~AKS_LOCATION_PLACEHOLDER~'"$AKS_LOCATION"'~' > $CREDS
        rm $CREDS.temp 2> /dev/null
        ;;
      gke)
        cp $CREDS $CREDS.temp
        cat $CREDS.temp | \
          sed 's~GKE_PROJECT_PLACEHOLDER~'"$GKE_PROJECT"'~' | \
          sed 's~GKE_CLUSTER_REGION_PLACEHOLDER~'"$GKE_CLUSTER_REGION"'~' | \
          sed 's~GKE_CLUSTER_ZONE_PLACEHOLDER~'"$GKE_CLUSTER_ZONE"'~' > $CREDS
        rm $CREDS.temp 2> /dev/null
        ;;
      ocp)
        ;;
    esac
    echo ""
    echo "The updated credentials file can be found here: $CREDS"
    echo ""
fi
