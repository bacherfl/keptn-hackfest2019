#!/bin/bash

echo "----------------------------------------------------"
echo Validating Kubectl configured to cluster
echo "----------------------------------------------------"
export KUBECTL_CONFIG=$(kubectl -n kube-system get pods | grep Running | wc -l | tr -d '[:space:]')
if [ $KUBECTL_CONFIG -eq 0 ]
then
    echo ">>> Unable Connect to Cluster using kubectl.  "
    echo "    Verify have configured ~/.kube/config file.  "
    echo "    Verify cluster is available."
    echo ""
    exit 1
fi
echo "Able to Connect to Cluster: '$(kubectl config current-context)'  using kubectl."