#!/bin/bash

function checkDependencies() {
  export KUBECONFIG=$1

  if [ -z "$KUBECONFIG" ]; then
    exit 1
  fi
}

function prepareToExecute() {
  export KUBECTL_CMD=$(which kubectl)
}

function fetchIngress() {
  eval "$KUBECTL_CMD get svc nginx \
                        -n frontend \
                        -o jsonpath='{.status.loadBalancer.ingress[0]}'"
}

function main() {
  prepareToExecute
  checkDependencies "$1"
  fetchIngress
}

main "$1"


