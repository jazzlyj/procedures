# export addresses and other vars
set -a
K8S_API_ENDPOINT=apiNode1.mydomain.io
K8S_API_ENDPOINT_INTERNAL=apiNode2.mydomain.io
K8S_API_ADDVERTISE_IP_1=apiNode1
K8S_VERSION=1.23.3
K8S_CLUSTER_NAME=<pickAname>
K8S_MASTER=<k8smaster1Name>
OUTPUT_DIR=$(realpath -m ./_clusters/${K8S_CLUSTER_NAME})
LOCAL_CERTS_DIR=${OUTPUT_DIR}/pki
KUBECONFIG=${OUTPUT_DIR}/kubeconfig
mkdir -p ${OUTPUT_DIR}
MASTER_SSH_ADDR_1=<yourusername>@${K8S_MASTER}
set +a