#!/bin/bash

if ! [ "$1" == "skip" ]; then
  clear
fi
echo "Gathering keptn-api-token and keptn endpoint..." 
KEPTN_ENDPOINT=https://control.keptn.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -o=jsonpath='{.data.keptn-api-token}' | base64 --decode)
GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')
GITHUB_USER_NAME=$(cat creds.json | jq -r '.githubUserName')
GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
KEPTN_PROJECT=$(cat creds.json | jq -r '.keptnProject')

echo "-----------------------------------------------------"
echo "About to configure keptn CLI and onboard this project:"
echo ""
echo "KEPTN endpoint               : $KEPTN_ENDPOINT"
echo "KEPTN API token              : $KEPTN_API_TOKEN"
echo "GitHub User Name             : $GITHUB_USER_NAME"
echo "GitHub Personal Access Token : $GITHUB_PERSONAL_ACCESS_TOKEN"
echo "GitHub Organization          : $GITHUB_ORGANIZATION" 
echo ""
echo "*** NOTE: This will first delete the keptn project repo:"
echo "          http://www.github.com/$GITHUB_ORGANIZATION/$KEPTN_PROJECT ***"
echo "-----------------------------------------------------"
if ! [ "$1" == "skip" ]; then
  read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
fi
echo ""
echo "-----------------------------------------------------"
echo "Deleting project $KEPTN_PROJECT if it exists"
echo "-----------------------------------------------------"
curl -s -X DELETE -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" "https://api.github.com/repos/$GITHUB_ORGANIZATION/$KEPTN_PROJECT"
echo ""
echo "-----------------------------------------------------"
echo "Running 'keptn create project $KEPTN_PROJECT' "
echo "-----------------------------------------------------"
keptn auth --endpoint=$KEPTN_ENDPOINT --api-token=$KEPTN_API_TOKEN
keptn configure --org=$GITHUB_ORGANIZATION --user=$GITHUB_USER_NAME --token=$GITHUB_PERSONAL_ACCESS_TOKEN
keptn create project $KEPTN_PROJECT ./keptn-onboarding/shipyard.yaml
echo ""
echo "Sleeping 60 sec to allow project to be registered"
sleep 60
echo ""

echo "-----------------------------------------------------"
echo "Running 'keptn onboard service'"
echo "-----------------------------------------------------"
echo "front-end"
keptn onboard service --project=$KEPTN_PROJECT --values=./keptn-onboarding/values_front-end.yaml
echo ""

echo "customer-service"
keptn onboard service --project=$KEPTN_PROJECT --values=./keptn-onboarding/values_customer-service.yaml
echo ""

echo "order-service"
keptn onboard service --project=$KEPTN_PROJECT --values=./keptn-onboarding/values_order-service.yaml
echo ""

echo "catalog-service"
keptn onboard service --project=$KEPTN_PROJECT --values=./keptn-onboarding/values_catalog-service.yaml
echo ""

echo "-----------------------------------------------------"
echo "Complete. View Keptn project files @ "
echo "  http://github.com/$GITHUB_ORGANIZATION/$KEPTN_PROJECT"
echo "-----------------------------------------------------"
