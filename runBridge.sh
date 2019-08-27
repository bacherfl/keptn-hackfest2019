#!/bin/bash

echo "======================================================================"
echo "Starting Keptn Bridge with this command:"
echo "while true; do kubectl port-forward svc/$(kubectl get ksvc bridge -n keptn -ojsonpath={.status.latestReadyRevisionName})-service -n keptn 9000:80; done"
echo ""
echo "Assumes your first ran: 8-setupBridgeProxy.sh"
echo ""
echo "View bridge @ http://$(curl -s ifconfig.me)/#/"
echo ""
echo "Hit Ctrl-C a few times to stop"
echo ""
while true; do kubectl port-forward svc/$(kubectl get ksvc bridge -n keptn -ojsonpath={.status.latestReadyRevisionName})-service -n keptn 9000:80; done