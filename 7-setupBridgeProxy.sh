#!/bin/bash

if ! [ "$1" == "skip" ]; then
  clear
fi
echo "======================================================================"

# Installation of haproxy
if ! [ -x "$(command -v haproxy)" ]; then
  echo "Installing 'haproxy' utility"
  sudo apt update
  sudo apt install haproxy -y
fi

# read the user/pass from the creds.json file
PROXY_USER_PLACEHOLDER=$(cat creds.json | jq -r '.keptnBridgeUser')
PROXY_PASSWORD_PLACEHOLDER=$(cat creds.json | jq -r '.keptnBridgePassword')

# generate the haproxy config file with these values
echo "Creating new /etc/haproxy/haproxy.cfg"
cat haproxy.template | \
      sed 's~PROXY_USER_PLACEHOLDER~'"$PROXY_USER_PLACEHOLDER"'~' | \
      sed 's~PROXY_PASSWORD_PLACEHOLDER~'"$PROXY_PASSWORD_PLACEHOLDER"'~' > haproxy.cfg

# copy new file to haproxy config directory
sudo cp haproxy.cfg /etc/haproxy/haproxy.cfg

echo "Restarting haproxy"
sudo service haproxy restart

echo ""
echo "======================================================================"
echo "Start Keptn Bridge with this command:"
echo "while true; do kubectl port-forward svc/bridge -n keptn 9000:8080; done"
echo ""
echo "View bridge @ http://$(curl -s ifconfig.me)/#/"