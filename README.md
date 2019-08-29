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

## 2. Github Org

Keptn expects all the code repos and project files to be in the same GitHub Organization. So create a github new github organization for the keptn-orders for Keptn to use and for the keptn-orders application repos to be forked.  See details in the [github docs](https://github.com/organizations/new)

Suggested gihub organization name: ```<your last name>-keptn-hackfest-<cloud provider>``` for example ```bacher-keptn-hackfest-gcloud```

NOTE: If the 'orders-project' repo already exists in your personal github org, there may be errors when you onboard again.  So delete the repo if it exists.

## 3. Tools

In this workshop we are going to use a pre-built Docker image that already has the required tools installed. The only requirement is that you have Docker installed on your machine. You can install it using the instructions on the [Docker Homepage](https://docs.docker.com/install/)

# Provision Cluster, Install Keptn, and onboard the Carts application

Now it's time to set up your workshop environment. During the setup, you will need the following values. We recommend to copy the following lines into an editor, fill them out and keep them as a reference for later:

```
Dynatrace Host Name (e.g. abc12345.live.dynatrace.com):
Dynatrace API Token:
Dynatrace PaaS Token:
GitHub User Name:
GitHub Personal Access Token:
GitHub User Email:
GitHub Organization:
========Azure Only=========
Azure Subscription ID:
Azure Location: germanywestcentral
========GKE Only===========
Google Project:
Google Cluster Zone: us-east1-b
Google Cluster Region: us-east1
```

The **Azure Subscription ID** can be found in your [Azure console](https://portal.azure.com/?quickstart=true#blade/Microsoft_Azure_Billing/SubscriptionsBlade)

The **Google Project** can be found at the top bar of your [GCP Console](https://console.cloud.google.com)


To start the docker container you will use for this workshop, please execute:

```
docker run -d -t bacherfl/keptn-demo
```

Afterwards, you can SSH into this container. First, retrieve the `CONTAINER_ID` of the `keptn-demo` container:

```
docker ps
```

Then, use that ID to SSH into the container:

```
docker exec -it <CONTAINER_ID> /bin/bash
```

When you are in the container, you need to log in to your PaaS account (GCP or AKS):

  - If you are using **GCP**, execute `gcloud init`
  - On **Azure**, execute `az login`

when is is done, navigate into the `scripts` folder:

```
cd scripts
```

Here you will find multiple scripts used for the setup and they must be run the right order.  Just run the setup script that will prompt you with menu choices.
```
./setup.sh <deployment type>
```
NOTE: Valid 'deployment type' argument values are:
* gke = Google
* aks = Azure

The setup menu should look like this:
```
====================================================
SETUP MENU for Azure AKS
====================================================
1)  Enter Installation Script Inputs
2)  Provision Kubernetes cluster
3)  Install Keptn
4)  Install Dynatrace
5)  Expose Keptn's Bridge
----------------------------------------------------
99) Delete Kubernetes cluster
====================================================
Please enter your choice or <q> or <return> to exit
```

## 1) Enter Installation Script Inputs

Before you do this step, be prepared with your github credentials, dynatrace tokens, and cloud provider project information available.

This will prompt you for values that are referenced in the remaining setup scripts. Inputted values are stored in ```creds.json``` file. For example on GKE the menus looks like:

```
===================================================================
Please enter the values for provider type: Google GKE:
===================================================================
Dynatrace Host Name (e.g. abc12345.live.dynatrace.com)
                                       (current: DYNATRACE_HOSTNAME_PLACEHOLDER) : 
Dynatrace API Token                    (current: DYNATRACE_API_TOKEN_PLACEHOLDER) : 
Dynatrace PaaS Token                   (current: DYNATRACE_PAAS_TOKEN_PLACEHOLDER) : 
GitHub User Name                       (current: GITHUB_USER_NAME_PLACEHOLDER) : 
GitHub Personal Access Token           (current: PERSONAL_ACCESS_TOKEN_PLACEHOLDER) : 
GitHub User Email                      (current: GITHUB_USER_EMAIL_PLACEHOLDER) : 
GitHub Organization                    (current: GITHUB_ORG_PLACEHOLDER) : 
Google Project                         (current: GKE_PROJECT_PLACEHOLDER) : 
Cluster Name                           (current: CLUSTER_NAME_PLACEHOLDER) : 
Cluster Zone (eg.us-east1-b)           (current: CLUSTER_ZONE_PLACEHOLDER) : 
Cluster Region (eg.us-east1)           (current: CLUSTER_REGION_PLACEHOLDER) :
```

## 2) Provision Kubernetes cluster

This will provision a Cluster on the specified cloud deployment type using the platforms CLI. This script will take several minutes to run and you can verify the cluster was created with the the cloud provider console.

The cluster will take 5-10 minutes to provision.

This script at the end will run the 'Validate Kubectl' script.  

## 3) Install Keptn

This will install the Keptn control plane components into your cluster.  The install will take 5-10 minutes to perform.

NOTE: Internally, this script will perform the following:
1. clone https://github.com/keptn/installer.  This repo has the cred.sav templates for building a creds.json file that the keptn CLI can use as an argument
1. use the values we already captured in the ```2-enterInstallationScriptInputs.sh``` script to create the creds.json file
1. run the ```keptn install -c=creds.json --platform=<Cluster>``` 
1. run the 'Show Keptn' helper script


## 4) Install Dynatrace
This will install the Dynatrace OneAgent Operator into your cluster.  The install will take 3-5 minutes to perform.

NOTE: Internally, this script will perform the following:
1. clone https://github.com/keptn/dynatrace-service.  This repo has scripts for each platform to install the Dyntrace OneAgent Operator and the cred_dt.sav template for building a creds_dt.json file that the install script expects to read
1. use the values we already captured in the ```1-enterInstallationScriptInputs.sh``` script to create the creds_dt.json file
1. run the ```/deploy/scripts/deployDynatraceOn<Platform>.sh``` script in the dynatrace-service folder
1. run the 'Show Dynatrace' helper script


## 5)  Expose Keptn's Bridge

The [keptn’s bridge](https://keptn.sh/docs/0.4.0/reference/keptnsbridge/) provides an easy way to browse all events that are sent within keptn and to filter on a specific keptn context. When you access the keptn’s bridge, all keptn entry points will be listed in the left column. Please note that this list only represents the start of a deployment of a new artifact and, thus, more information on the executed steps can be revealed when you click on one event.

<img src="images/bridge-empty.png" width="500"/>

In the default installation of Keptn, the bridge is only accessible via `kubectl port-forward`. To make things easier for workshop participants, we will expose it by creating a oublic URL for this component.

# Onboarding the carts service

Now that your environment is up and running and monitored by Dynatrace, you can proceed with onboarding the carts application into your cluster.
To do so, please follow these instructions:

1. Quit the setup script you were using to setup the infrastructure.
1. Navigate to the workshop directory:

```
cd /usr/keptn/keptn-hackfest2019
```
1. Go to https://github.com/keptn-sockshop/carts and click on the **Fork** button on the top right corner.

  1. Select the GitHub organization you use for keptn.

  1. Clone the forked carts service to your local machine. Please note that you have to use your own GitHub organization.

  ```
  git clone https://github.com/your-github-org/carts.git
  ```


1. Change into the `keptn-onboarding` directory:

```
cd keptn-onboarding
```

1. Create the `sockshop` project:

```
keptn create project sockshop shipyard.yaml
```

This will create a configuration repository in your github repository. This repository will contain a branch for each of the stages defined in the shipyard file, in order to store the desired configuration of the application within that stage.

1. Since the `sockshop` project does not contain any services yet, it is time to onboard a service into the project. In this workshop, we will use a simple microservice that emulates the behavior of a shopping cart. This service is written in Java Spring and uses a mongoDB database to store data. To onboard the `carts` service, execute the following command:

```
keptn onboard service --project=sockshop --values=values_carts.yaml
```

To deploy the database, execute:

```
keptn onboard service --project=sockshop --values=values_carts_db.yaml --deployment=deployment_carts_db.yaml --service=service_carts_db.yaml
```

Now, your configuration repository contains all the information needed to deploy your application and even supports blue/green deployments for two of the environments (staging and production)!

# Deploying the carts service

To deploy the service into your cluster, you can use the keptn CLI to trigger a new deployment. To do so, please execute the following command on your machine:

```
keptn send event new-artifact --project=sockshop --service=carts --image=docker.io/keptnexamples/carts --tag=0.8.1
```

This will inform keptn about the availability of a new artifact (`keptnexamples/carts:0.8.1`). As a result, keptn will trigger a multi-stage deployment of that service. During the deployment of the service, a number of various different services that are responsible for different tasks are involved, such as:

  - **github-service**: This service modifies the configuration stored in the repository in order to specify the desired image for the carrts service to be deployed (in that case `keptnexamples/carts:0.8.1`).
  - **helm-service**: This service checks out the configuration repository and deploys the service using `helm`.
  - **jmeter-service**: Responsible for running jmeter tests which are specified in the code repository of the `carts` service.
  - **pitometer-service**: Evaluates performance test runs, if quality gates are enabled (more on that later).
  - **gatekeeper-service**: Decides wether an artifact should be promoted into the next stage (e.g. from dev to staging), or if an artifact should be rejected.

To gain an overview of all services involved in the deployment/release of the service, you can use the **keptn's bridge**, which you have set up earlier.

# View the carts service

To make the carts service accesible from outside the cluster, and to support blue/green deployments, keptn automaticalliy creates Istio VirtualServices that direct requests to certain URLs to the correct service instance. You can retrieve the URLs for the carts service for each stage as follows:

```
echo http://carts.sockshop-dev.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
echo http://carts.sockshop-staging.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
echo http://carts.sockshop-production.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
```

Navigate to the URLs to inspect your carts service. In the production namespace, you should receive an output similar to this:

<img src="images/carts-production.png" width="500"/>

# Introducing quality gates

Since you have already set up your cluster to be monitored by Dynatrace, keptn can use its information to evaluate performance tests and to decide wether an artifact should be promoted, based on quality gates. Quality gates allow you to define limits for certain metrics (such as the response time of a service) that must not be exceeded by a service. If these criteria are met, an artifact will be allowed to proceed to the nest stage, otherwise the deployment will be rolled back automatically. You can specify quality gates in a file called `perfspec/perfspec.json` within the code repository of the respective service (`carts` in our case).
After forking the `carts` repository into your organization, the `perfspec` directory within that repository contains two files:

  - `perfspec_dynatrace.json`
  - `perfspec_prometheus.json`

In this workshop we will be using Dynatrace to retrieve metrics. Thus, to enable the Dynatrace quality gates, please rename `perfspec_dynatrace.json` to `perfspec.json`, and commit/push your changes to the repository. To do so, either execute the following commands on your machine, or rename the file directly within the GitHub UI.

```
cd ~/respositories/carts
mv perfspec_dynatrace.json perfspec.json
git add .
git commit -m "enabled quality gates using dynatrace"
git push
```

Now your carts service will only be promoted into production if it adheres to the quality gates (response time < 1s) specified in the `perfspec.json` file.

## Deployment of a slow implementation of the carts service

To demonstrate the benefits of having quality gates, we will now deploy a version of the carts service with a terribly slow response time. To trigger the deployment of this version, please execute the following command on your machine:

```
keptn send event new-artifact --project=sockshop --service=carts --image=docker.io/keptnexamples/carts --tag=0.8.2
```

After some time, this new version will be deployed into the `dev` stage. If you look into the `shipyard.yaml` file that you used to create the `sockshop` project, you will see that in this stage, only functional tests are executed. This means that even though version has a slow response time, it will be promoted into the `staging` environment, because it is working as expected on a functional level. You can verify the deployment of the new version into `staging` by navigating to the URL of the service in your browser using the following URL:

```
echo http://carts.sockshop-staging.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')
```

On the info homepage of the service, the **Version** should now be set to **v2**, and the **Delay in ms** value should be set to **1000**. (Note that it can take a few minutes until this version is deployed after sending the `new-artifact` event.)

As soon as this version has been deployed into the `staging` environment, the `jmeter-service` will execute the performance tests for this service. When those are finished, the `pitometer-service` will evaluate them using Dynatrace as a data source. At this point, it will detect that the response time of the service is too high and mark the evaluation of the performance tests as `failed`.

As a result, the new artifact will not be promoted into the `production` stage. Additionally, the traffic routing within the `staging` stage will be automatically updated in order to send requests to the previous version of the service. You can again verify that by navigating to the service homepage and inspecting the **Version** property. This should now be set to **v1** again.

# Runbook Automation and Self Healing

## About this use case

Configuration changes during runtime are sometimes necessary to increase flexibility. A prominent example are feature flags that can be toggled also in a production environment. In this use case, we will change the promotion rate of a shopping cart service, which means that a defined percentage of interactions with the shopping cart will add promotional items (e.g., small gifts) to the shopping carts of our customers. However, we will experience troubles with this configuration change. Therefore, we will set means in place that are capable of auto-remediating issues at runtime. In fact, we will leverage workflows in ServiceNow. 

## Prerequisites

- ServiceNow instance or [free ServiceNow developer instance](https://developer.servicenow.com) 
- Use case tested on [London](https://docs.servicenow.com/category/london) and [Madrid](https://docs.servicenow.com/category/london) releases
- On the bstion host, clone the GitHub repository with the necessary files for the use case:
  
  ```
  git clone --branch 0.1.3 https://github.com/keptn/servicenow-service.git --single-branch
  cd servicenow-service
  ```

## Configure keptn

In order for keptn to use both ServiceNow and Dynatrace, the corresponding credentials have to be stored as Kubernetes secrets in the cluster. 

### Dynatrace secret 

This has already been setup at the beginning of the workshop

### ServiceNow secret 

Create the ServiceNow secret to allow keptn to create/update incidents in ServiceNow and run workflows. For the command below, use your ServiceNow tenant id (8-digits), your ServiceNow user (e.g., *admin*) as user, and your ServiceNow password as token:

```
kubectl -n keptn create secret generic servicenow --from-literal="tenant=xxx" --from-literal="user=xxx" --from-literal="token=xxx"
```
Please note that if your ServiceNow password has some special characters in it, you need to [escape them](https://kubernetes.io/docs/concepts/configuration/secret/).

## Setup the workflow in ServiceNow

A ServiceNow *Update Set* is provided to run this use case. To install the *Update Set* follow these steps:

1. Login to your ServiceNow instance.
1. Look for *update set* in the left search box and navigate to **Update Sets to Commit** 

    <img src="images/runbook-automation/assets/service-now-update-set-overview.png" width="500"/>

1. Click on **Import Update Set from XML** 

1. *Import* and *Upload* the file from your file system that you find in your `servicenow-service/usecase` folder: `keptn_demo_remediation_updateset.xml`

1. Open the *Update Set*

    <img src="images/runbook-automation/assets/service-now-update-set-list.png" width="500"/>

1. In the right upper corner, click on **Preview Update Set** and once previewed, click on **Commit Update Set** to apply it to your instance

    <img src="images/runbook-automation/assets/service-now-update-set-commit.png" width="500"/>

1. After importing, enter **keptn** as the search term into the upper left search box.

    <img src="images/runbook-automation/assets/service-now-keptn-creds.png" width="500"/>

1. Click on **New** and enter your Dynatrace API token as well as your Dynatrace tenant.

1. *(Optional)* You can also take a look at the predefined workflow that is able to handle Dynatrace problem notifications and remediate issues.
    - Navigate to the workflow editor by typing **Workflow Editor** and clicking on the item **Workflow** > **Workflow Editor**
    - The workflow editor is opened in a new window/tab
    - Look for the workflow **keptn_demo_remediation** (it might as well be on the second or third page)
    <img src="images/runbook-automation/assets/service-now-workflow-list.png" width="500"/>
    - Open the workflow by clicking on it. It will look similar to the following image. By clicking on the workflow notes you can further investigate each step of the workflow.
    <img src="images/runbook-automation/assets/service-now-keptn-workflow.png" width="500"/>

## (optional): Verify Dynatrace problem notification

During the [setup of Dynatrace](../../monitoring/dynatrace) a problem notification has already been set up for you. You can verify the correct setup by following the instructions: 

1. Login to your Dynatrace tenant.
1. Navigate to **Settings** > **Integration** > **Problem notifications**
1. Click on **Set up notifications** and select **Custom integration**
1. Click on **keptn remediation**
1. The problem notification should look similar to the one in this screen shot:

    <img src="images/runbook-automation/assets/dynatrace-problem-notification-integration.png" width="500"/>

## Adjust anomaly detection in Dynatrace

The Dynatrace platform is built on top of AI, which is great for production use cases, but for this demo we have to override some default settings in order for Dynatrace to trigger the problem.

Before you adjust this setting, make sure to have some traffic on the service in order for Dynatrace to detect and list the service. The easiest way to generate traffic is to use the provided file `add-to-carts.sh` in the `./usecase` folder. This script will add items to the shopping cart and can be stopped after a couple of added items by hitting <kbd>CTRL</kbd>+<kbd>C</kbd>.

1. Navigate to the _servicenow-service/usecase_ folder: 
    ```
    cd usecase
    ```

1. Run the script:
    ```
    ./add-to-cart.sh "carts.sockshop-production.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')"
    ```

1. Once you generated some load, navigate to **Transaction & services** and find the service **ItemsController** in the _sockshop-production_ environment. 

2. Open the service and click on the three dots button to **Edit** the service.
    <img src="images/runbook-automation/assets/dynatrace-service-edit.png" width="500"/>

1. In the section **Anomaly detection** override the global anomaly detection and set the value for the **failure rate** to use **fixed thresholds** and to alert if **10%** custom failure rate are exceeded. Finally, set the **Sensitiviy** to **High**.
    <img src="images/runbook-automation/assets/dynatrace-service-anomaly-detection.png" width="500"/>

## Run the use case

Now, all pieces are in place to run the use case. Therefore, we will start by generating some load on the `carts` service in our production environment. Afterwards, we will change configuration of this service at runtime. This will cause some troubles in our production environment, Dynatrace will detect the issue, and will create a problem ticket. Due to the problem notification we just set up, keptn will be informed about the problem and will forward it to the ServiceNow service that in turn creates an incident in ServiceNow. This incident will trigger a workflow that is able to remediate the issue at runtime. Along the remediation, comments, and details on configuration changes are posted to Dynatrace.

### Load generation

1. Run the script:
    ```
    ./add-to-cart.sh "carts.sockshop-production.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')"
    ```

1. You should see some logging output each time an item is added to your shopping cart:
    ```
    ...
    Adding item to cart...
    {"id":"3395a43e-2d88-40de-b95f-e00e1502085b","itemId":"03fef6ac-1896-4ce8-bd69-b798f85c6e0b","quantity":73,"unitPrice":0.0}
    Adding item to cart...
    {"id":"3395a43e-2d88-40de-b95f-e00e1502085b","itemId":"03fef6ac-1896-4ce8-bd69-b798f85c6e0b","quantity":74,"unitPrice":0.0}
    Adding item to cart...
    {"id":"3395a43e-2d88-40de-b95f-e00e1502085b","itemId":"03fef6ac-1896-4ce8-bd69-b798f85c6e0b","quantity":75,"unitPrice":0.0}
    ...
    ```

### Configuration change at runtime

1. Open another terminal to make sure the load generation is still running and again, navigate to the _servicenow-service/usecase_ folder.

1. _(Optional:)_ Verify that the environment variables you set earlier are still available:
    ```
    echo $DT_TENANT
    echo $DT_API_TOKEN
    ```

    If the environment variables are not set, you can easily set them by [following the instructions on how to extract information from the Dynatrace secret](#dynatrace-secret). 


1. Run the script:
    ```
    ./enable-promotion.sh "carts.sockshop-production.$(kubectl get cm keptn-domain -n keptn -o=jsonpath='{.data.app_domain}')" 30
    ```
    Please note the parameter `30` at the end, which is the value for the configuration change and can be interpreted as for 30 % of the shopping cart interactions a special item is added to the shopping cart. This value can be set from `0` to `100`. For this use case the value `30` is just fine.

1. You will notice that your load generation script output will include some error messages after applying the script:
    ```
    ...
    Adding item to cart...
    {"id":"3395a43e-2d88-40de-b95f-e00e1502085b","itemId":"03fef6ac-1896-4ce8-bd69-b798f85c6e0b","quantity":80,"unitPrice":0.0}
    Adding item to cart...
    {"timestamp":1553686899190,"status":500,"error":"Internal Server Error","exception":"java.lang.Exception","message":"promotion campaign not yet implemented","path":"/carts/1/items"}
    Adding item to cart...
    {"id":"3395a43e-2d88-40de-b95f-e00e1502085b","itemId":"03fef6ac-1896-4ce8-bd69-b798f85c6e0b","quantity":81,"unitPrice":0.0}
    ...
    ```

### Problem detection by Dynatrace

Navigate to the ItemsController service by clicking on **Transactions & services** and look for your ItemsController. Since our service is running in three different environment (dev, staging, and production) it is recommended to filter by the `environment:sockshop-production` to make sure to find the correct service.
    <img src="images/runbook-automation/assets/dynatrace-services.png" width="500"/>

When clicking on the service, in the right bottom corner you can validate in Dynatrace that the configuration change has been applied.
    <img src="images/runbook-automation/assets/dynatrace-config-event.png" width="500"/>


After a couple of minutes, Dynatrace will open a problem ticket based on the increase of the failure rate.
    <img src="images/runbook-automation/assets/dynatrace-problem-open.png" width="500"/>


### Incident creation & workflow execution by ServiceNow

The Dynatrace problem ticket notification is sent out to keptn which puts it into the problem channel where the ServiceNow service is subscribed. Thus, the ServiceNow service takes the event and creates a new incident in ServiceNow. 
In your ServiceNow instance, you can take a look at all incidents by typing in **incidents** in the top-left search box and click on **Service Desk** > **Incidents**. You should be able to see the newly created incident, click on it to view some details.
    <img src="images/runbook-automation/assets/service-now-incident.png" width="500"/>

After creation of the incident, a workflow is triggered in ServiceNow that has been setup during the import of the *Update Set* earlier. The workflow takes a look at the incident, resolves the URL that is stored in the *Remediation* tab in the incident detail screen. Along with that, a new custom configuration change is sent to Dynatrace. Besides, the ServiceNow service running in keptn sends comments to the Dynatrace problem to be able to keep track of executed steps.

You can check both the new _custom configuration change_ on the service overview page in Dynatrace as well as the added comment on the problem ticket in Dynatrace.

Once the problem is resolved, Dynatrace sends out another notification which again is handled by the ServiceNow service. Now the incidents gets resolved and another comment is sent to Dynatrace. The image shows the updated incident in ServiceNow. The comment can be found if you navigate to the closed problem ticket in Dynatrace. 
     <img src="images/runbook-automation/assets/service-now-incident-resolved.png" width="500"/>

## Troubleshooting

- Please note that Dynatrace has its feature called **Frequent Issue Detection** enabled by default. This means, that if Dynatrace detects the same problem multiple times, it will be classified as a frequent issue and problem notifications won't be sent out to third party tools. Therefore, the use case might not be able to be run a couple of times in a row. 
To disable this feature:
  1. Login to your Dynatrace tenant.
  1. Navigate to **Settings** > **Anomaly detection** > **Frequent issue detection**
  1. Toggle the switch at **Detect frequent issues within transaction and services**

- In ServiceNow you can take a look at the **System Log** > **All** to verify which actions have been executed. You should be able to see some logs on the execution of the keptn demo workflow as shown in the screenshot:
    <img src="images/runbook-automation/assets/service-now-systemlog.png" width="500"/>



- In case Dynatrace detected a problem before the [ServiceNow secret was created](#servicenow-secret) in your Kubernetes cluster, the remediation will not work. Resolution:
    1. [Create the secret](#servicenow-secret).
    1. Restart the pod.
    
    ```
    kubectl delete pod servicenow-service-XXXXX -n keptn
    ```
