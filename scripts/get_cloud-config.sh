#!/bin/bash
FILE=../$NAME-cloud-config-output.txt
if [ ! -f "$FILE" ]; then
    curl -sfL https://raw.githubusercontent.com/harvester/cloud-provider-harvester/master/deploy/generate_addon.sh | bash -s cloud-provider-$PART_ID default > $FILE
fi
export CLOUD_CONFIG_DATA=$(cat $FILE | grep -A 10 cloud-init |grep content | sed -e "s| *content: ||g")

cat <<EOF
{"cloud-config": "${CLOUD_CONFIG_DATA}", "harvester-kubeconfig": "$(cat ../$NAME-rke2.yaml | base64 -w0)"}
EOF
# cat <<EOF

# export CLUSTER_NAME=test-rk
# export NAMESPACE=example-rke2
# export KUBERNETES_VERSION=v1.26.6
# export SSH_KEYPAIR=$SSH_KEYPAIR
# export VM_IMAGE_NAME=$VM_IMAGE_NAME
# export CONTROL_PLANE_MACHINE_COUNT=3
# export WORKER_MACHINE_COUNT=2
# export RANCHER_TURTLES_LABEL='    cluster-api.cattle.io/rancher-auto-import: "true"'
# export HARVESTER_ENDPOINT=https://$HARVESTER_HOST:6443
# export VM_NETWORK=$VM_NETWORK
# export HARVESTER_KUBECONFIG_B64=$(cat ../$NAME-rke2.yaml | base64 -w0)

# EOF

# cat <<EOF | sed -e "1i ---" | sed -e "s|^|    |g" | sed -e "1i  export CLOUD_CONFIG_SECRET='"
# apiVersion: v1
# data:
#   cloud-config: ${CLOUD_CONFIG_DATA}
# kind: Secret
# metadata:
#   creationTimestamp: null
#   name: cloud-config
#   namespace: kube-system'
# EOF
