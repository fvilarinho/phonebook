#!/bin/bash

function checkDependencies() {
  if [ -z "$KUBECONFIG" ]; then
    echo "kubeconfig is not defined!"

    exit 1
  fi
}

function applyBackendConfigMaps() {
  $KUBECTL_CMD create configmap phonebook-logging-settings \
                                --from-file=logback.xml=../etc/logback.xml \
                                -n backend \
                                -o yaml \
                                --dry-run=client | $KUBECTL_CMD apply -f -
}

function applyFrontendConfigMaps() {
  $KUBECTL_CMD create configmap nginx-settings-template \
                                --from-file=default.conf.template=../etc/nginx.conf.k8s \
                                -n frontend \
                                -o yaml \
                                --dry-run=client | $KUBECTL_CMD apply -f -

  $KUBECTL_CMD create configmap nginx-tls-certificate \
                                --from-file=fullchain.pem=../etc/tls/certs/fullchain.pem \
                                -n frontend \
                                -o yaml \
                                --dry-run=client | $KUBECTL_CMD apply -f -

  $KUBECTL_CMD create configmap nginx-tls-certificate-key \
                                --from-file=privkey.pem=../etc/tls/private/privkey.pem \
                                -n frontend \
                                -o yaml \
                                --dry-run=client | $KUBECTL_CMD apply -f -

  $KUBECTL_CMD create configmap nginx-auth \
                                --from-file=.htpasswd=../etc/.htpasswd \
                                -n frontend \
                                -o yaml \
                                --dry-run=client | $KUBECTL_CMD apply -f -
}

function applyConfigMaps() {
  applyBackendConfigMaps
  applyFrontendConfigMaps
}

function main () {
  checkDependencies
  applyConfigMaps
}

main
