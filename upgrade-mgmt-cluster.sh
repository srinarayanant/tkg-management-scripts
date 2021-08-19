#!/usr/bin/env bash

#==============================================================================#
#  FILE : upgrade-mgmt-cluster.sh                                              #
#  USAGE: ./upgrade-mgmt-cluster.sh                                            #
#  DESCRIPTION : Script to upgrade TKG management cluster to version 1.3.1     #
#  Environment variables to be preset :                                        #
#    1. TKG_MGMT_CLUSTER_KUBECONFIG_PATH: Management cluster context file path #
#    2. TKG_MGMT_CLUSTER_CONTEXT: Management cluster context name              #
#    3. TKG_MGMT_CLUSTER_NAME : Management cluster name                        #
#==============================================================================#

#-- Enable/Disable debug
#set -x

export MGMT_CLUSTER_KUBECONFIG_PATH="${TKG_MGMT_CLUSTER_KUBECONFIG_PATH}"
export MGMT_CLUSTER_CONTEXT="${TKG_MGMT_CLUSTER_CONTEXT}"
export MGMT_CLUSTER_NAME="${TKG_MGMT_CLUSTER_NAME}"

tanzu login --kubeconfig ${MGMT_CLUSTER_KUBECONFIG_PATH} \
            --context ${MGMT_CLUSTER_CONTEXT} \
            --name ${MGMT_CLUSTER_NAME}
export KUBECONFIG=${MGMT_CLUSTER_KUBECONFIG_PATH}

rm -rf ~/.tanzu/tkg/bom
export TKG_BOM_CUSTOM_IMAGE_TAG="v1.3.1-patch1"
tanzu management-cluster create || ls

echo "***  Display management cluster status ***" 
tanzu management-cluster get

echo "***  Upgrading management cluster : ${TKG_MGMT_CLUSTER_NAME} ***" 
tanzu management-cluster upgrade --yes

echo "***  Display management cluster status post upgrade ***" 
tanzu management-cluster get
