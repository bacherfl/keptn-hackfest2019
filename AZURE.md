# Azure bastion host VM

Below are instructions for using the Azure CLI to provison an ubuntu virtual machine on Azure to use for the cluster, keptn, and application setup.

# Create bastion host

These instructions assume you have an Azure subscription and have the AZ CLI installed and configured locally.
 
You can also make the bastion host from the console and then continue with the steps to connect using ssh.  But you must use this image as to have the install scripts be compatible:
* Ubuntu 16.04 LTS

## 1. Install and configure the Azure CLI 

On your laptop, run these commands to configure the Azure CLI [Azure docs](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)

Once installed, run these commands to configure the cli:

```
# login to your account.  This will ask you to open a browser with a code and then login.
az login

# verify you are on the right subscription.  Look for "isDefault": true
az account list --output table
```

## 2. Provision bastion host using CLI

On your laptop, run these commands to provision the VM and a resource group
```
# adjust these variables
export VM_GROUP_LOCATION=eastus
export RESOURCE_PREFIX=<example your last name>

# leave these values
export VM_GROUP_NAME="$RESOURCE_PREFIX"-keptn-orders-bastion-group
export VM_NAME="$RESOURCE_PREFIX"-keptn-orders-bastion

# provision the host
az group create --name $VM_GROUP_NAME --location $VM_GROUP_LOCATION

# create the VM
az vm create \
  --name $VM_NAME \
  --resource-group $VM_GROUP_NAME \
  --size Standard_B1s \
  --image Canonical:UbuntuServer:16.04-LTS:latest \
  --generate-ssh-keys \
  --output json \
  --verbose

# open port for haproxy to keptn bridge
az vm open-port --resource-group $VM_GROUP_NAME --name $VM_NAME --port 80
```

## 3. SSH bastion host

Goto the Azure console and choose the "connect" menu on the VM row to copy the connection string. Run this command to SSH to the new VM.
```
ssh <your id>@<host ip>
```

## 4. Clone the Orders setup repo

Within the VM, run these commands to clone the setup repo.
```
git clone --branch 0.4.0 https://github.com/keptn-orders/keptn-orders-setup.git --single-branch
cd keptn-orders-setup
```
Finally, proceed to the [Provision Cluster, Install Keptn, and onboard the Orders application](README.md#installation-scripts-from-setup-menu) step.

# Delete bastion host

## Option 1 - delete using azure cli

From your laptop, run these commands to delete the resource group. 
This will delete the bastion host resource group and the VM running within it.
```
# adjust these variables
export RESOURCE_PREFIX=<example your last name>
# leave these values
export VM_GROUP_NAME="$RESOURCE_PREFIX"-keptn-orders-bastion-group

az group delete --name $VM_GROUP_NAME --yes
```

## Option 2 - delete from the Azure console

On the resource group page, delete the resource group named 'kube-demo-group'. 
This will delete the bastion host resource group and the VM running in it.

# az command reference

```
# list of locations
az account list-locations -o table

# list vm VMs
az vm show --name keptn-orders-bastion

# list vm sizes
az vm list-sizes --location eastus -o table

# image types
az vm image list -o table
az vm image show --urn Canonical:UbuntuServer:16.04-LTS:latest
```
