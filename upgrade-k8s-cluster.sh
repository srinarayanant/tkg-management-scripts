#!/usr/bin/env bash

#==============================================================================#
#  FILE : upgrade-k8s-cluster.sh                                               #
#  USAGE: ./upgrade-k8s-cluster.sh                                             #
#  DESCRIPTION : Script to upgrade TKG workload cluster to version 1.3.1       #
#  Environment variables to be preset :                                        #
#    1. TKG_MGMT_CLUSTER_KUBECONFIG_PATH: Management cluster context file path #
#    2. TKG_MGMT_CLUSTER_CONTEXT: Management cluster context name              #
#    3. TKG_MGMT_CLUSTER_NAME : Management cluster name                        #
#    4. TKG_K8S_CLUSTER_NAME: Kubernetes cluster name                          #
#    5. TKG_K8S_CLUSTER_NAMESPACE: Kubernetes cluster namespace                #
#==============================================================================#

#-- Enable/Disable debug
#set -x

export MGMT_CLUSTER_KUBECONFIG_PATH="${TKG_MGMT_CLUSTER_KUBECONFIG_PATH}"
export MGMT_CLUSTER_CONTEXT="${TKG_MGMT_CLUSTER_CONTEXT}"
export MGMT_CLUSTER_NAME="${TKG_MGMT_CLUSTER_NAME}"

export K8S_CLUSTER_NAME="${TKG_K8S_CLUSTER_NAME}"
export K8S_CLUSTER_NAMESPACE="${TKG_K8S_CLUSTER_NAMESPACE}"

tanzu login --kubeconfig ${MGMT_CLUSTER_KUBECONFIG_PATH} \
            --context ${MGMT_CLUSTER_CONTEXT} \
            --name ${MGMT_CLUSTER_NAME}
export KUBECONFIG=${MGMT_CLUSTER_KUBECONFIG_PATH}

rm -rf ~/.tanzu/tkg/bom
export TKG_BOM_CUSTOM_IMAGE_TAG="v1.3.1-patch1"
tanzu management-cluster create || ls

echo "***  Display Kubernetes cluster details ***" 
tanzu cluster list

echo "***  Import kubeconfig for workload cluster into kube context ***"
tanzu cluster kubeconfig get ${K8S_CLUSTER_NAME} -n ${K8S_CLUSTER_NAMESPACE} --admin

echo "***  Switch to kubernetes cluster context  ***"
kubectl config use-context ${K8S_CLUSTER_NAME}-admin@${K8S_CLUSTER_NAME}

echo "***  Delete kapp controller and associated constructs ***"
kubectl delete deployment kapp-controller -n kapp-controller
kubectl delete clusterrole kapp-controller-cluster-role
kubectl delete clusterrolebinding kapp-controller-cluster-role-binding
kubectl delete serviceaccount kapp-controller-sa -n kapp-controller

echo "***  Upgrade Kubernetes cluster : ${K8S_CLUSTER_NAME} ***" 
tanzu cluster upgrade ${K8S_CLUSTER_NAME} --namespace ${K8S_CLUSTER_NAMESPACE} --yes

echo "***  Display Kubernetes cluster details post upgrade ***" 
tanzu cluster list
