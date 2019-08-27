# Google bastion host overview

Below are instructions for using the Google CLI to provison an ubuntu virtual machine on Azure to use for the cluster, keptn, and application setup.

# Create bastion host

These instructions assume you have an Google account and have the Google CLI installed and configured locally.
 
You can also make the bastion host from the console and then continue with the steps to connect using ssh.  But you must use this image as to have the install scripts be compatible:
* Ubuntu Server 16.04 LTS

## 1. Install and configure the gcloud cli

Below are instructions for using the gcloud CLI to provison an ubuntu virtual machine on Google. This bastion host will then be used to run the scripts to provision the GKE cluster, keptn, and application setup.

## 1. Install and configure the gcloud CLI

These instructions assume you have an Google account and have the gcloud CLI installed and configured locally.

See [CLI for Google Cloud](https://cloud.google.com/sdk/gcloud/) for local CLI installation and configuration.

Once installed, run this command to configure the cli:

```gcloud init```

At the prompt, follow these steps
* Choose option 'Log in with a new account'
* Choose 'Y' to continue using personal account
* Copy the URL to a browser and paste the verification code once you login
* Paste the verification code
* Choose default project
* Choose option to pick default region and zone. For example: [2] us-east1-c"

When complete, run this command ```gcloud config list``` to see your config.

When complete, run this command ```gcloud compute instances list``` to see your google hosts

## 2. Create bastion host using gcloud CLI

Run this commands on your laptop or the Google web shell to create the bastion host.

```
# adjust these variables
export RESOURCE_PREFIX=<example your last name>
export GKE_PROJECT=<your google project name for example: gke-keptn-orders >
export GKE_CLUSTER_ZONE=<example us-east1-c>

# provision the host
gcloud compute instances create "$RESOURCE_PREFIX"-keptn-orders-bastion \
--project $GKE_PROJECT \
--zone $GKE_CLUSTER_ZONE \
--image-project="ubuntu-os-cloud" \
--image-family="ubuntu-1604-lts" \
--machine-type="g1-small" \
--tags="http-server"
```

NOTE: You can also make the bastion host from the console, and the continue with the steps to connect using ssh.  But you must use this image as to have the install scripts be compatible.
* Ubuntu 16.04 LTS
* amd64 xenial image built on 2019-03-25

REFERENCE: [Google docs](https://cloud.google.com/sdk/gcloud/reference/compute/instances/create)

## 3. SSH to the bastion host using gcloud

Run this commands on your laptop or the Google web shell to SSH to the new bastion host.
```
gcloud compute --project $GKE_PROJECT ssh --zone $GKE_CLUSTER_ZONE "$RESOURCE_PREFIX"-keptn-orders-bastion
```

## 4. Clone the Orders setup repo

Within the bastion host, run these commands to clone the setup repo.

```
git clone --branch 0.4.0 https://github.com/keptn-orders/keptn-orders-setup.git --single-branch
cd keptn-orders-setup
```

## 5. Complete the keptn setup

Finally, proceed to the [Provision Cluster, Install Keptn, and onboard the Orders application](README.md#installation-scripts-from-setup-menu) step.

# Delete the bastion host

From you laptop or the Google web shell, run this command to delete the bastion host. [Google docs](https://cloud.google.com/sdk/gcloud/reference/compute/instances/delete)

```
# adjust these variables
export RESOURCE_PREFIX=<example your last name>
export GKE_PROJECT=<your google project name for example: gke-keptn-orders >
export GKE_CLUSTER_ZONE=<example us-east1-c>

# delete the bastion host
gcloud compute instances delete "$RESOURCE_PREFIX"-keptn-orders-bastion \
--project $GKE_PROJECT \
--zone $GKE_CLUSTER_ZONE
```

# Other gcloud command reference

```
# list available images
gcloud compute images list

# list available machine types
gcloud compute machine-types list
```