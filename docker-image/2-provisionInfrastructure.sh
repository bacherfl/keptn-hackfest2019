#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

if ! [ "$2" == "skip" ]; then  
  clear
fi
START_TIME=$(date)
case $DEPLOYMENT in
  eks)
    ./provisionEks.sh $2
    
    EKS_DOMAIN=$(cat creds.json | jq -r '.eksDomain')
    EKS_ELB=$(kubectl get svc istio-ingressgateway -n istio-system -o=json | jq -r '.status.loadBalancer.ingress[0].hostname')

    echo "-------------------------------------------------------"
    echo "Update your AWS Route 53 DNS alias to this ELB Public External IP"
    echo "EKS_DOMAIN : $EKS_DOMAIN"
    echo "EKS_ELB    : $EKS_ELB"
    echo "-------------------------------------------------------"
    read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key

    ;;
  aks)
    ./provisionAks.sh $2
    ;;
  gke)
    ./provisionGke.sh $2
    ;;
  *)
    echo "Deploy for $DEPLOYMENT not supported"
    exit 1
    ;;
esac

if [[ $? != 0 ]]; then
  echo ""
  echo "ABORTING due to provisioning error"
  exit 1
fi

# adding some sleep for validateKubectl sometimes fails, if cluster not fully ready
sleep 20

echo "===================================================="
echo "Finished provisioning $DEPLOYMENT_NAME Cluster"
echo "===================================================="
echo "Script start time : $START_TIME"
echo "Script end time   : "$(date)

# validate that have kubectl configured first
./validateKubectl.sh
if [ $? -ne 0 ]
then
  exit 1
fi
