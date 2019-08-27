#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

echo "To install keptn, please execute the following command:"
echo "keptn install -c=creds.json --platform=$DEPLOYMENT"