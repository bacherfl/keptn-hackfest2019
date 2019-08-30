#!/bin/bash

echo "--------------------------------------------------------------------------"
echo "kubectl -n keptn get pods"
echo "--------------------------------------------------------------------------"
kubectl -n keptn get pods
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl -n keptn get configmaps"
echo "--------------------------------------------------------------------------"
kubectl -n keptn get configmaps
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get svc istio-ingressgateway -n istio-system"
kubectl get svc istio-ingressgateway -n istio-system
echo "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl -n keptn get svc"
kubectl -n keptn get svc 
echo "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get pods -n istio-system"
kubectl get pods -n istio-system
echo "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl -n keptn get deployments"
kubectl -n keptn get deployments
echo "--------------------------------------------------------------------------"
echo ""
echo "--------------------------------------------------------------------------"
echo "kubectl get ns"
kubectl get ns
echo "--------------------------------------------------------------------------"
echo ""
KEPTN_ENDPOINT=https://control.keptn.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -o=jsonpath='{.data.keptn-api-token}' | base64 --decode)
echo "KEPTN_ENDPOINT  = $KEPTN_ENDPOINT"
echo "KEPTN_API_TOKEN = $KEPTN_API_TOKEN"