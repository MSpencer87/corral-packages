#!/bin/bash
set -ex

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

echo "$CORRAL_registry_cert" | base64 -d > /opt/corral/rancher/tls.crt
echo "$CORRAL_registry_key" | base64 -d > /opt/corral/rancher/tls.key

CORRAL_rancher_host=${CORRAL_rancher_host:="${CORRAL_fqdn}"}
CORRAL_rancher_version=${CORRAL_rancher_version:=$(helm search repo rancher-latest/rancher -o json | jq -r .[0].version)}
minor_version=$(echo "$CORRAL_kubernetes_version" | cut -d. -f2)

kubectl create namespace cattle-system

if [ "$minor_version" -gt 24 ]; then
    helm upgrade --install rancher rancher-latest/rancher --namespace cattle-system --set global.cattle.psp.enabled=false --set hostname=$CORRAL_rancher_host --version=$CORRAL_rancher_version --set ingress.tls.source=secret
else
    helm upgrade --install rancher rancher-latest/rancher --namespace cattle-system --set hostname=$CORRAL_rancher_host --version=$CORRAL_rancher_version --set ingress.tls.source=secret
fi

kubectl -n cattle-system create secret tls tls-rancher-ingress --cert=/opt/corral/rancher/tls.crt --key=/opt/corral/rancher/tls.key

echo "corral_set rancher_version=$CORRAL_rancher_version"
echo "corral_set rancher_host=$CORRAL_rancher_host"