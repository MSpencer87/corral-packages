#!/bin/bash
#set -ex

function corral_set() {
    echo "corral_set $1=$2"
}

function corral_log() {
    echo "corral_log $1"
}

if [[ $CORRAL_rancher_version == "2.5.*" ]]; then
  echo "corral_set bootstrap_password=admin"
  return 0
fi

echo "waiting for bootstrap password"
until [ "$(kubectl -n cattle-system get secret/bootstrap-secret -o json --ignore-not-found=true | jq -r '.data.bootstrapPassword | length > 0')" == "true" ]; do
  sleep 0.1
  echo -n "."
done
echo

echo "corral_set bootstrap_password=$(kubectl -n cattle-system get secret/bootstrap-secret -o json | jq -r '.data.bootstrapPassword' | base64 -d)"

bootstrap_password=$(kubectl -n cattle-system get secret/bootstrap-secret -o json | jq -r '.data.bootstrapPassword' | base64 -d)

corral_log "Rancher instance running at: https://$CORRAL_rancher_host/dashboard/?setup=$bootstrap_password"