#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

# validate that have dynatrace tokens and URL configure properly
# by testing the connection
./validateDynatrace.sh
if [ $? -ne 0 ]
then
  exit 1
fi

# get values needed for file
SOURCE_CREDS_FILE=creds.json

DT_SERVICE_BRANCH=$(cat creds.json | jq -r '.dynatraceServiceBranch')
DT_HOSTNAME=$(cat $SOURCE_CREDS_FILE | jq -r '.dynatraceHostName')
DT_URL="https://$DYNATRACE_HOSTNAME"
DT_API_TOKEN=$(cat $SOURCE_CREDS_FILE | jq -r '.dynatraceApiToken')
DT_PAAS_TOKEN=$(cat $SOURCE_CREDS_FILE | jq -r '.dynatracePaaSToken')

echo "-------------------------------------------------------"
echo "Cloning dynatrace service repo and building credential file"

DT_SERVICE_GIT_REPO=https://github.com/keptn/dynatrace-service
echo -e "Cloning $DT_SERVICE_GIT_REPO branch $DT_SERVICE_BRANCH"
rm -rf dynatrace-service
git clone --branch $DT_SERVICE_BRANCH $DT_SERVICE_GIT_REPO --single-branch

cd dynatrace-service/deploy/scripts

echo "-------------------------------------------------------"
echo "Creating Keptn credential files"

KEPTN_DTCREDS_SAVE_FILE=creds_dt.sav
KEPTN_DTCREDS_FILE=creds_dt.json
rm $KEPTN_DTCREDS_FILE 2> /dev/null

cat $KEPTN_DTCREDS_SAVE_FILE | \
  sed 's~DYNATRACE_TENANT_PLACEHOLDER~'"$DT_HOSTNAME"'~' | \
  sed 's~DYNATRACE_API_TOKEN~'"$DT_API_TOKEN"'~' | \
  sed 's~DYNATRACE_PAAS_TOKEN~'"$DT_PAAS_TOKEN"'~' >> $KEPTN_DTCREDS_FILE

echo ""
echo "======================================================="
echo About to install Dynatrace with these parameters:
echo ""
echo "cat creds_dt.json"
cat creds_dt.json
echo "======================================================="
if ! [ "$2" == "skip" ]; then  
  read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
fi
echo ""

echo "-------------------------------------------------------"
echo "Running deployDynatrace script.  This will take several minutes"
echo "-------------------------------------------------------"

START_TIME=$(date)
case $DEPLOYMENT in
  gke)
    ./deployDynatraceOnGKE.sh
    ;;
  aks)
    ./deployDynatraceOnAKS.sh
    ;;
  eks)
    ./deployDynatraceOnGKE.sh
    ;;
  *)
    echo "Skipping deployDynatrace. $DEPLOYMENT_NAME not supported"
    exit
    ;;
esac

cd ../../..

# adding some sleep for Dyntrace to be ready
sleep 60

echo "-------------------------------------------------------"
echo "Finished Running deployDynatrace script"
echo "-------------------------------------------------------"
echo "Script start time : $START_TIME"
echo "Script end time   : "$(date)

echo "-------------------------------------------------------"
# show Dynatrace
./showDynatrace.sh

echo ""
echo "Choose the 'Show Dyntrace' menu option to verify that Dynatrace pods"
echo "for 'dynatrace-oneagent-operator' and 'oneagent' are in 'Running' status"

