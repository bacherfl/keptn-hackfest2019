#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o=json | jq -r .status.loadBalancer.ingress[].ip)
KEPTN_PROJECT=$(cat creds.json | jq -r '.keptnProject')
EKS_DOMAIN=$(cat creds.json | jq -r '.eksDomain')
     
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl -n $KEPTN_PROJECT-dev get svc"
kubectl -n $KEPTN_PROJECT-dev get svc
echo "--------------------------------------------------------------------------"
echo "Orders Application:"
echo "--------------------------------------------------------------------------"
case $DEPLOYMENT in
  eks)
    echo "Dev running        @ http://front-end.$KEPTN_PROJECT-dev.$EKS_DOMAIN/"
    echo "Staging running    @ http://front-end.$KEPTN_PROJECT-staging.$EKS_DOMAIN/"
    echo "Production running @ http://front-end.$KEPTN_PROJECT-production.$EKS_DOMAIN/"
    ;;
  *)
    echo "Dev running        @ http://front-end.$KEPTN_PROJECT-dev.$INGRESS_IP.xip.io/"
    echo "Staging running    @ http://front-end.$KEPTN_PROJECT-staging.$INGRESS_IP.xip.io/"
    echo "Production running @ http://front-end.$KEPTN_PROJECT-production.$INGRESS_IP.xip.io/"
    ;;
esac

echo "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get pods -n $KEPTN_PROJECT-dev"
kubectl get pods -n $KEPTN_PROJECT-dev
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get pods -n $KEPTN_PROJECT-staging"
kubectl get pods -n $KEPTN_PROJECT-staging
echo "--------------------------------------------------------------------------"
echo "kubectl get pods -n $KEPTN_PROJECT-production"
kubectl get pods -n $KEPTN_PROJECT-production
