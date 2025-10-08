#!/bin/bash

# Création d'un cluster Kind pour les premiers pas Kubernetes
unset KUBECONFIG

# Nom du cluster spécifique à ce TD
CLUSTER_NAME="premiers-pas-k8s"
REGISTRY_NAME="kind-registry-premiers-pas"
REGISTRY_PORT="5001"

# Nettoyer le cluster existant s'il y en a un
kind delete cluster --name ${CLUSTER_NAME}

echo "Création du cluster ${CLUSTER_NAME} pour les premiers pas..."

# Créer le registry si il n'existe pas
running="$(docker inspect -f '{{.State.Running}}' "${REGISTRY_NAME}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${REGISTRY_PORT}:5000" --name "${REGISTRY_NAME}" \
    registry:2
fi

# Connecter le registry au réseau kind
docker network connect "kind" "${REGISTRY_NAME}" || true

# Créer le cluster avec une configuration simple
cat <<EOF | kind create cluster --name ${CLUSTER_NAME} --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
  - containerPort: 443
    hostPort: 8443
    protocol: TCP
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
- role: worker
- role: worker
networking:
  podSubnet: "10.244.0.0/16"
  apiServerPort: 6443
EOF

sleep 5

# Générer le kubeconfig
kind get kubeconfig --name ${CLUSTER_NAME} > kubeconfig-${CLUSTER_NAME}

echo "Cluster ${CLUSTER_NAME} créé avec succès !"
echo "Pour utiliser ce cluster, exécutez :"
echo "export KUBECONFIG=\$(pwd)/kubeconfig-${CLUSTER_NAME}"

# Configurer le registry local
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${REGISTRY_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

echo "Configuration terminée !"