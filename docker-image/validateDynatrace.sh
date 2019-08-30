#!/bin/bash

echo "-------------------------------------------------------"
echo Validating Dynatrace 
echo "-------------------------------------------------------"

DYNATRACE_HOSTNAME=$(cat creds.json | jq -r '.dynatraceHostName')
DYNATRACE_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')
DYNATRACE_PAAS_TOKEN=$(cat creds.json | jq -r '.dynatracePaaSToken')

if [ $DYNATRACE_HOSTNAME == "DYNATRACE_HOSTNAME_PLACEHOLDER" ]
then
  echo DYNATRACE_HOSTNAME is not set properly.
  exit 1
fi
if [ $DYNATRACE_API_TOKEN == "DYNATRACE_API_TOKEN_PLACEHOLDER" ]
then
  echo DT_API_TOKEN is not set properly.
  exit 1
fi
if [ $DYNATRACE_PAAS_TOKEN == "DYNATRACE_PAAS_TOKEN_PLACEHOLDER" ]
then
  echo DT_PAAS_TOKEN is not set properly.
  exit 1
fi
echo "All variables in creds.json are set"

echo ""
echo "----------------------------------------------------------"
echo Validating Dynatrace PaaS token is configured properly ...
echo "----------------------------------------------------------"
DT_URL="https://$DYNATRACE_HOSTNAME/api/v1/time?Api-Token=$DYNATRACE_PAAS_TOKEN"
if [ "$(curl -sL -w '%{http_code}' $DT_URL -o /dev/null)" != "200" ]

then
    echo ">>> Unable to connect using Dynatrace PaaS token.  Verify you have the right token and environment ID (aka tenant)"
    echo ""
    exit 1
fi
echo "Able to connect to 'https://$DYNATRACE_HOSTNAME/api' using PaaS token."
echo ""
echo "----------------------------------------------------------"
echo Validating Dynatrace API token is configured properly ...
echo "----------------------------------------------------------"
DT_URL="https://$DYNATRACE_HOSTNAME/api/config/v1/autoTags?Api-Token=$DYNATRACE_API_TOKEN"
if [ "$(curl -sL -w '%{http_code}' $DT_URL -o /dev/null)" != "200" ]
then
    echo ">>> Unable to connect using API Token.  Verify you have the right API Token"
    echo ""
    exit 1
fi
echo "Able to connect to 'https://$DYNATRACE_HOSTNAME/api' using API token."
echo ""
echo "-------------------------------------------------------"
echo Dynatrace valdiation complete
echo "-------------------------------------------------------"
echo ""