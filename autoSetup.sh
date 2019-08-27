
#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

clear

./1-installPrerequisitesTools.sh $DEPLOYMENT skip 2>&1 | tee logs/1-installPrerequisitesTools.log

echo "Autosetup for $DEPLOYMENT_NAME"
echo "Optionally copy in your creds.json file now to save data entry"
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

./2-enterInstallationScriptInputs.sh $DEPLOYMENT 2>&1 | tee logs/2-enterInstallationScriptInputs.log

./3-provisionInfrastructure.sh $DEPLOYMENT skip  2>&1 | tee logs/3-provisionInfrastructure.log

./4-installKeptn.sh $DEPLOYMENT skip 2>&1 | tee logs/4-installKeptn.log

./5-installDynatrace.sh $DEPLOYMENT skip 2>&1 | tee logs/5-installDynatrace.log

./6-forkApplicationRepositories.sh skip  2>&1 | tee logs/6-forkApplicationRepositories.log

./7-onboardOrderApp.sh skip  2>&1 | tee logs/7-onboardOrderApp.log

./8-setupBridgeProxy.sh skip 2>&1 | tee logs/8-setupBridgeProxy.log
