#!/bin/bash

echo ""
echo "-------------------------------------------------------------------------------"
echo "kubectl -n dynatrace get pods"
echo "-------------------------------------------------------------------------------"
kubectl -n dynatrace get pods
echo ""
echo "-------------------------------------------------------------------------------"
echo "kubectl get secret dynatrace -n keptn -o yaml"
echo "-------------------------------------------------------------------------------"
kubectl get secret dynatrace -n keptn -o yaml
echo ""

