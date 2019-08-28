#!/bin/bash

clear

# once support multiple providers, then add this back
# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

show_menu(){
echo ""
echo "===================================================="
echo "SETUP MENU for $DEPLOYMENT_NAME"
echo "===================================================="
echo "1)  Install Prerequisites Tools"
echo "2)  Enter Installation Script Inputs"
echo "3)  Provision Kubernetes cluster"
echo "4)  Install Keptn"
echo "5)  Install Dynatrace"
echo "6)  Fork sockshop Repos"
echo "7)  Setup HA Proxy to Keptn Bridge"
echo "----------------------------------------------------"
echo "10) Validate Kubectl"
echo "11) Validate Prerequisite Tools"
echo "----------------------------------------------------"
echo "20) Show Orders App"
echo "21) Show Keptn"
echo "22) Show Dynatrace"
echo "----------------------------------------------------"
echo "30) Send Keptn Artifact Events"
echo "----------------------------------------------------"
echo "99) Delete Kubernetes cluster"
echo "===================================================="
echo "Please enter your choice or <q> or <return> to exit"
read opt
}

show_menu
while [ opt != "" ]
    do
    if [[ $opt = "" ]]; then 
        exit;
    else
        clear
        case $opt in
        1)
                ./1-installPrerequisitesTools.sh $DEPLOYMENT  2>&1 | tee logs/1-installPrerequisitesTools.log
                show_menu
                ;;
        2)
                ./2-enterInstallationScriptInputs.sh $DEPLOYMENT 2>&1 | tee logs/2-enterInstallationScriptInputs.log
                show_menu
                ;;
        3)
                ./3-provisionInfrastructure.sh $DEPLOYMENT  2>&1 | tee logs/3-provisionInfrastructure.log
                show_menu
                ;;
        4)
                ./4-installKeptn.sh 2>&1 | tee logs/4-installKeptn.log
                show_menu
                ;;
        5)
                ./5-installDynatrace.sh 2>&1 | tee logs/5-installDynatrace.log
                show_menu
                ;;
        6)
                ./6-forkApplicationRepositories.sh  2>&1 | tee logs/6-forkApplicationRepositories.log
                show_menu
                ;;
        7)
                ./7-setupBridgeProxy.sh  2>&1 | tee logs/8-setupBridgeProxy.log
                show_menu
                ;;
        10)
                ./validateKubectl.sh  2>&1 | tee logs/validateKubectl.log
                show_menu
                ;;
        11)
                ./validatePrerequisiteTools.sh $DEPLOYMENT 2>&1 | tee logs/validatePrerequisiteTools.log
                show_menu
                ;;
        20)
                ./showApp.sh  2>&1 | tee logs/showApp.log
                show_menu
                ;;
        30)
                ./sendArtifactEvents.sh | tee logs/sendArtifactEvents.log
                show_menu
                ;;                
        21)
                ./showKeptn.sh  2>&1 | tee logs/showKeptn.log
                show_menu
                ;;
        22)
                ./showDynatrace.sh  2>&1 | tee logs/showDynatrace.log
                show_menu
                ;;
        99)
                ./deleteCluster.sh $DEPLOYMENT 2>&1 | tee logs/deleteCluster.log
                show_menu
                ;;
        q)
           	break
           	;;
        *) 
            	echo "invalid option"
            	show_menu
            	;;
    esac
fi
done