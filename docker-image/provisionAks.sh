#!/bin/bash

# values read in from creds file
AKS_SUBSCRIPTION_ID=$(cat creds.json | jq -r '.aksSubscriptionId')
AKS_LOCATION=$(cat creds.json | jq -r '.aksLocation')
RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')
AKS_VERSION=1.12.8
AKS_NODE_SIZE=Standard_B4ms

# derived values
CLUSTER_NAME="$RESOURCE_PREFIX"-keptn-orders-cluster
AKS_RESOURCEGROUP="$RESOURCE_PREFIX"-keptn-orders-group
AKS_DEPLOYMENTNAME="$RESOURCE_PREFIX"-keptn-orders-deployment
AKS_SERVICE_PRINCIPAL="$RESOURCE_PREFIX"-keptn-orders-sp

echo "===================================================="
echo "About to provision Azure Resources with these inputs: "
echo "The provisioning will take several minutes"
echo ""
echo "AKS_SUBSCRIPTION_ID   : $AKS_SUBSCRIPTION_ID"
echo "AKS_LOCATION          : $AKS_LOCATION"
echo "AKS_RESOURCEGROUP     : $AKS_RESOURCEGROUP"
echo "AKS_CLUSTER_NAME      : $CLUSTER_NAME"
echo "AKS_DEPLOYMENTNAME    : $AKS_DEPLOYMENTNAME"
echo "AKS_SERVICE_PRINCIPAL : $AKS_SERVICE_PRINCIPAL"
echo "===================================================="
if ! [ "$1" == "skip" ]; then
  read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
fi
echo ""

echo "------------------------------------------------------"
echo "Creating Resource group: $AKS_RESOURCEGROUP"
echo "------------------------------------------------------"
az account set -s $AKS_SUBSCRIPTION_ID
az group create --name "$AKS_RESOURCEGROUP" --location $AKS_LOCATION
az group show --name "$AKS_RESOURCEGROUP"

echo "Letting resource group persist properly (10 sec) ..."
sleep 10 

# need to look up service principal id and then delete it
# this is outside of the resource group
AKS_SERVICE_PRINCIPAL_APPID=$(az ad sp list --display-name $AKS_SERVICE_PRINCIPAL | jq -r '.[0].appId | select (.!=null)')
if [ -n "$AKS_SERVICE_PRINCIPAL_APPID" ]
then
    echo "------------------------------------------------------"
    echo "Deleting Service Principal     : $AKS_SERVICE_PRINCIPAL"
    echo "AKS_SERVICE_PRINCIPAL_APPID  : $AKS_SERVICE_PRINCIPAL_APPID"
    echo "------------------------------------------------------"
    az ad sp delete --id $AKS_SERVICE_PRINCIPAL_APPID
fi

echo "------------------------------------------------------"
echo "Creating Service Principal: $AKS_SERVICE_PRINCIPAL"
echo "------------------------------------------------------"
az ad sp create-for-rbac -n "http://$AKS_SERVICE_PRINCIPAL" \
    --role contributor \
    --scopes /subscriptions/"$AKS_SUBSCRIPTION_ID"/resourceGroups/"$AKS_RESOURCEGROUP" > ./aks/AKS_service_principal.json
AKS_APPID=$(jq -r .appId ./aks/AKS_service_principal.json)
AKS_APPID_SECRET=$(jq -r .password ./aks/AKS_service_principal.json)

echo "Letting service principal persist properly (30 sec) ..."
sleep 30 
echo "Generated Serice Principal App ID: $AKS_APPID"
 
# prepare cluster parameters file values
jq -n \
    --arg owner "$RESOURCE_PREFIX" \
    --arg name "$CLUSTER_NAME" \
    --arg location "$AKS_LOCATION" \
    --arg dns "$AKS_LOCATION-dns" \
    --arg agentvmsize "$AKS_NODE_SIZE" \
    --arg appid "$AKS_APPID" \
    --arg appidsecret "$AKS_APPID_SECRET" \
    --arg kubernetesversion "$AKS_VERSION" \ '{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "resourceName": {
            "value": $name
        },
        "owner": {
            "value": $owner
        },
        "location": {
            "value": $location
        },
        "dnsPrefix": {
            "value": $dns
        },
        "agentCount": {
            "value": 1
        },
        "agentVMSize": {
            "value": $agentvmsize
        },
        "servicePrincipalClientId": {
            "value": $appid
        },
        "servicePrincipalClientSecret": {
            "value": $appidsecret
        },
        "kubernetesVersion": {
            "value": $kubernetesversion
        },
        "networkPlugin": {
            "value": "kubenet"
        },
        "enableRBAC": {
            "value": true
        },
        "enableHttpApplicationRouting": {
            "value": false
        }
    }
}' > ./aks/parameters.json

echo "------------------------------------------------------"
echo "Creating cluster with these parameters:"
cat ./aks/parameters.json
echo 
echo "AKS_APPID=$AKS_APPID"
echo "AKS_APPID_SECRET=$AKS_APPID_SECRET"
echo "------------------------------------------------------"
echo "Create Cluster will take several minutes"
echo ""

cd aks
./deploy.sh -i $AKS_SUBSCRIPTION_ID -g $AKS_RESOURCEGROUP -n $AKS_DEPLOYMENTNAME -l $AKS_LOCATION
cd ..

echo "Letting cluster persist properly (10 sec) ..."
sleep 10

echo "Updated Kubectl with credentials"
echo "az aks get-credentials --resource-group $AKS_RESOURCEGROUP --name $CLUSTER_NAME --overwrite-existing"
az aks get-credentials --resource-group $AKS_RESOURCEGROUP --name $CLUSTER_NAME --overwrite-existing

echo "===================================================="
echo "Azure cluster deployment complete."
echo "===================================================="
echo ""