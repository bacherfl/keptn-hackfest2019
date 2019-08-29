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
echo "1)  Enter Installation Script Inputs"
echo "2)  Provision Kubernetes cluster"
echo "3)  Install Keptn"
echo "4)  Install Dynatrace"
echo "5)  Expose Keptn's Bridge"
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
                ./1-enterInstallationScriptInputs.sh $DEPLOYMENT 2>&1 | tee logs/1-enterInstallationScriptInputs.log
                show_menu
                ;;
        2)
                ./2-provisionInfrastructure.sh $DEPLOYMENT  2>&1 | tee logs/2-provisionInfrastructure.log
                show_menu
                ;;
        3)
                ./3-installKeptn.sh 2>&1 | tee logs/3-installKeptn.log
                show_menu
                ;;
        4)
                ./4-installDynatrace.sh 2>&1 | tee logs/4-installDynatrace.log
                show_menu
                ;;
        5)
                ./5-exposeBridge.sh 2>&1 | tee logs/5-exposeBridge.log
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
