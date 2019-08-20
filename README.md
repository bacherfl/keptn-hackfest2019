# keptn-hackfest2019
Instructions for the workshop "Building unbreakable automated multi-stage pipelines with keptn" given @Lakeside Hackfest 2019

# Overview
In this workshop, you will get hands-on experience with the open source framework [keptn](https://keptn.sh), and see how it can help you to manage your cloud-native applications on Kubernetes

# Pre-requisites

## 1. Accounts

1. Dynatrace - Assumes you will use a [trial SaaS dynatrace tenant](https://www.dynatrace.com/trial) and created a PaaS and API token.  See details in the [keptn docs](https://keptn.sh/docs/0.4.0/monitoring/dynatrace/)
1. GitHub - Assumes you have a github account and a personal access token with the persmissions keptn expects. See details in the [keptn docs](https://keptn.sh/docs/0.4.0/installation/setup-keptn-gke/)
1. Cloud provider account.  Highly recommend to sign up for personal free trial as to have full admin rights and to not cause any issues with your enterprise account. Links to free trials
   * [Google](https://cloud.google.com/free/)
   * [Azure](https://azure.microsoft.com/en-us/free/)
#   * [Amazon](https://aws.amazon.com/free/)

## 2. Github Org

Keptn expects all the code repos and project files to be in the same GitHub Organization. So create a github new github organization for the keptn-orders for Keptn to use and for the keptn-orders application repos to be forked.  See details in the [github docs](https://github.com/organizations/new)

Suggested gihub organization name: ```<your last name>-keptn-orders-<cloud provider>``` for examaple ```jahn-keptn-orders-aks```

NOTE: If the 'orders-project' repo already exists in your personal github org, there may be errors when you onboard again.  So delete the repo if it exists.

## 3. Tools

The following set of tools are required by the installation scripts and interacting with the environment.  The setup scripts will install these automatically on the bastion host, but below is a listing for reference.

All platforms
* keptn -[Keptn CLI to manage Keptn projects](https://keptn.sh/docs/0.4.0/reference/cli/)
* kubectl - [CLI to manage the cluster](https://kubernetes.io/docs/tasks/tools/install-kubectl). This is required for all, but will use the installation instructions per each cloud provider

Google additional tools
* gcloud - [CLI for Google Cloud](https://cloud.google.com/sdk/gcloud/)

Azure additional tools
* az - [CLI for Azure](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

#Amazon additional tools
#* ekscli - [CLI Provisioning EKS cluster](https://github.com/weaveworks/eksctl)
#* aws-iam-authenticator = [Allows kubectl client to work with Amazon EKS via IAM](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
#* aws - [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

