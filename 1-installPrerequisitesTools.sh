#!/bin/bash

# verify first running on Ubuntu for the installation scripts
# assume that
if [ "$(uname -a | grep Ubuntu)" == "" ]; then
  echo "Must be running on Ubuntu to run this script"
  exit 1
fi

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

# specify versions to install
# https://github.com/github/hub/releases
HUB_VERSION=2.12.3
#gke
#https://cloud.google.com/sdk/docs/quickstart-linux
GKE_SDK=google-cloud-sdk-258.0.0-linux-x86_64.tar.gz
# eks
# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
EKS_KUBECTL_VERSION=https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/kubectl
# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
EKS_IAM_AUTHENTICATOR_VERSION=https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
EKS_EKSCTL_VERSION=latest_release
# aks
# az aks get-versions --location eastus --output table
AKS_KUBECTL_VERSION=1.11.9

if ! [ "$2" == "skip" ]; then  
  clear
fi
echo "======================================================================"
echo "About to install required tools"
echo "Deployment Type: $DEPLOYMENT_NAME"
echo ""
echo "NOTE: this will download and copy the executable into /usr/local/bin"
echo "      if the utility finds a value when running 'command -v <utility>'"
echo "      that utility will be concidered already installed"
echo ""
echo "Named Versions to be installed:"
echo "  HUB_VERSION                   : $HUB_VERSION"
case $DEPLOYMENT in
  eks)
    echo "  EKS_IAM_AUTHENTICATOR_VERSION : $EKS_IAM_AUTHENTICATOR_VERSION"
    echo "  EKS_KUBECTL_VERSION           : $EKS_KUBECTL_VERSION"
    echo "  EKS_EKSCTL_VERSION            : $EKS_EKSCTL_VERSION"
    ;;
esac
echo "======================================================================"
if ! [ "$2" == "skip" ]; then
  read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
fi

# Installation of hub
# https://github.com/github/hub/releases
if ! [ -x "$(command -v hub)" ]; then
  echo "----------------------------------------------------"
  echo "Downloading git 'hub' utility ..."
  rm -rf hub-linux-amd64-$HUB_VERSION*
  wget https://github.com/github/hub/releases/download/v$HUB_VERSION/hub-linux-amd64-$HUB_VERSION.tgz
  tar -zxvf hub-linux-amd64-$HUB_VERSION.tgz
  echo "Installing git 'hub' utility ..."
  sudo ./hub-linux-amd64-$HUB_VERSION/install
  rm -rf hub-linux-amd64-$HUB_VERSION*
fi

# Installation of jq
# https://github.com/stedolan/jq/releases
if ! [ -x "$(command -v jq)" ]; then
  echo "----------------------------------------------------"
  echo "Installing 'jq' utility ..."
  sudo apt-get update
  sudo apt-get --assume-yes install jq
fi

# Installation of yq
# https://github.com/mikefarah/yq
if ! [ -x "$(command -v yq)" ]; then
  echo "----------------------------------------------------"
  echo "Installing 'yq' utility ..."
  sudo apt-get update
  sudo add-apt-repository ppa:rmescandon/yq -y
  sudo apt update
  sudo apt install yq -y
fi

# Installation of bc
if ! [ -x "$(command -v bc)" ]; then
  echo "----------------------------------------------------"
  echo "Installing 'bc' utility ..."
  sudo apt-get update
  sudo apt-get install bc -y
fi
  
# Installation of keptn cli
# https://keptn.sh/docs/0.4.0/reference/cli/
KEPTN_CLI_VERSION=$(cat creds.json | jq -r '.keptnBranch')
if ! [ -x "$(command -v keptn)" ]; then
  echo "----------------------------------------------------"
  echo "Downloading 'keptn' utility version $KEPTN_CLI_VERSION..."
  rm -rf keptn-linux*
  case $DEPLOYMENT in
    eks)
      # this is a development branch
      wget https://storage.googleapis.com/keptn-cli/20190820.0817-latest/keptn-linux.zip keptn-linux.zip
      sudo apt install unzip -y
      unzip keptn-linux.zip
      ;;
    *)
      #wget https://github.com/keptn/keptn/releases/download/"$KEPTN_CLI_VERSION"/"$KEPTN_CLI_VERSION"_keptn-linux.tar.gz
      #tar -zxvf keptn-linux.tar.gz
      wget https://github.com/keptn/keptn/releases/download/"$KEPTN_CLI_VERSION"/"$KEPTN_CLI_VERSION"_keptn-linux.tar
      tar -zxvf "$KEPTN_CLI_VERSION"_keptn-linux.tar
      ;;
  esac

  echo "Installing 'keptn' utility ..."
  chmod +x keptn
  sudo mv keptn /usr/local/bin/keptn
fi

case $DEPLOYMENT in
  eks)
    # AWS CLI
    if ! [ -x "$(command -v aws)" ]; then
      echo "----------------------------------------------------"
      echo "Installing 'aws cli' ..."
      rm get-pip.py
      curl -O https://bootstrap.pypa.io/get-pip.py
      python3 get-pip.py --user
      pip3 install awscli --upgrade --user
    fi
    # kubectl
    if ! [ -x "$(command -v kubectl)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'kubectl' ..."
      rm kubectl
      curl -o kubectl $EKS_KUBECTL_VERSION 
      echo "Installing 'kubectl' ..."
      chmod +x ./kubectl
      sudo mv kubectl /usr/local/bin/kubectl
    fi
    # aws-iam-authenticator
    if ! [ -x "$(command -v aws-iam-authenicator)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'aws-iam-authenticator' ..."
      rm aws-iam-authenticator
      curl -o aws-iam-authenticator $EKS_IAM_AUTHENTICATOR_VERSION
      echo "Installing 'aws-iam-authenticator' ..."
      chmod +x ./aws-iam-authenticator
      sudo mv aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
    fi
    # eksctl - utility used to provison eks cluster
    if ! [ -x "$(command -v eksctl)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'eksctl' ..."
      rm -rf eksctl*.tar.gz
      rm -rf eksctl
      curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/$EKS_EKSCTL_VERSION/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C .
      sudo mv eksctl /usr/local/bin/eksctl
    fi
    ;;
  ocp)
    # Openshift specific tools
    if ! [ -x "$(command -v oc)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'oc' ..."
      wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz 
      echo "Installing 'oc' ..."
      tar xzf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
      cd openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit
      chmod +x oc
      mv oc /usr/local/bin/oc
      rm -rf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit* 
    fi
    ;;
  aks)
    # az cli
    # https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
    if ! [ -x "$(command -v az)" ]; then
      echo "----------------------------------------------------"
      echo "Get packages needed for the install process"
      sudo apt-get update
      sudo apt-get install curl apt-transport-https lsb-release gpg
      echo "Download and install the Microsoft signing key"
      curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor | \
      sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
      echo "Add the Azure CLI software repository"
      AZ_REPO=$(lsb_release -cs)
      echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
      sudo tee /etc/apt/sources.list.d/azure-cli.list
      echo "Update repository information and install the azure-cli package"
      sudo apt-get update
      sudo apt-get install azure-cli
    fi
    # need to do this since the kubectl install uses az
    echo ""
    echo "****************************************************"
    echo "****************************************************"
    echo "You need to initialize the cloud provider CLI."
    echo ""
    echo "az login"
    echo "  This will ask you to open a browser with a code"
    echo "  and then to pick your azure login."
    echo "****************************************************"
    echo "****************************************************"
    az login
    # kubectl
    if ! [ -x "$(command -v kubectl)" ]; then
      echo "----------------------------------------------------"
      echo "Downloading 'kubectl' ..."
      sudo az aks install-cli --client-version $AKS_KUBECTL_VERSION
    fi
    ;;
  gke)
    # Google specific tools
    if ! [ -x "$(command -v gcloud)" ]; then
      echo "----------------------------------------------------"
      echo "Installing gcloud"
      rm -rf $GKE_SDK
      rm -rf google-cloud-sdk/
      curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$GKE_SDK
      tar zxvf $GKE_SDK google-cloud-sdk
      ./google-cloud-sdk/install.sh
    fi

    # Google specific tools
    if ! [ -x "$(command -v kubectl)" ]; then
      echo "----------------------------------------------------"
      echo "Installing kubectl"
      # https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl
      sudo apt-get update && sudo apt-get install -y apt-transport-https
      curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
      echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
      sudo apt-get update
      sudo apt-get install -y kubectl
    fi
    # sudo apt-get upgrade google-cloud-sdk --Yes
    ;;
esac

echo ""
echo "===================================================="
echo "Installation complete."
echo "===================================================="

# run a final validation
./validatePrerequisiteTools.sh $DEPLOYMENT

case $DEPLOYMENT in
  eks)
    echo ""
    echo "****************************************************"
    echo "****************************************************"
    echo "You need to initialize the cloud provider CLI."
    echo ""
    echo "'aws configure' values to use"
    echo "  enter your AWS Access Key ID"
    echo "  enter your AWS Secret Access Key ID"
    echo "  enter Default region name example us-east-1"
    echo "  Default output format, enter json"
    echo "****************************************************"
    echo "****************************************************"
    aws configure
    ;;
  gke)
    echo ""
    echo "****************************************************"
    echo "****************************************************"
    echo "You need to initialize the cloud provider CLI."
    echo ""
    echo "'gcloud init' values to use"
    echo "  Choose option '[2] Log in with a new account'"
    echo "  Choose 'Y' for 'Are you sure you want to "
    echo "     authenticate with your personal account?'"
    echo "  Copy the URL to a browser and copy the verification code once you login"
    echo "  Paste the verification code"
    echo "  Choose default project"
    echo "  Choose 'Y' for 'Do you want to configure a "
    echo "     default Compute Region and Zone?'"
    echo "  Choose option to pick default region and zone"
    echo "    for example: [2] us-east1-c"
    echo ""
    echo "  Run 'gcloud config list' to view what you entered."
    echo "****************************************************"
    echo "****************************************************"
    gcloud init
    ;;
esac
