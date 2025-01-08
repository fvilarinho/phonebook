#!/bin/bash

function checkDependencies() {
  if [ -z "$KUBECONFIG" ]; then
    echo "kubeconfig is not defined!"

    exit 1
  fi
}

function applyDatabaseSecrets() {
  $KUBECTL_CMD create secret generic mariadb \
                                     --from-literal=DB_USER=$DB_USER \
                                     --from-literal=DB_PASS=$DB_PASS \
                                     --from-literal=DB_NAME=$DB_NAME \
                                     --from-literal=DB_ROOT_PASS=$DB_ROOT_PASS \
                                     -n database \
                                     -o yaml \
                                     --dry-run=client | $KUBECTL_CMD apply -f -
}

function applyBackendSecrets() {
  $KUBECTL_CMD create secret generic phonebook \
                                     --from-literal=DB_HOST=$DB_HOST.database.svc.cluster.local \
                                     --from-literal=DB_USER=$DB_USER \
                                     --from-literal=DB_PASS=$DB_PASS \
                                     --from-literal=DB_NAME=$DB_NAME \
                                     --from-literal=METRICS_HOST=$METRICS_HOST.monitoring.svc.cluster.local \
                                     --from-literal=TRACES_HOST=$TRACES_HOST.monitoring.svc.cluster.local \
                                     --from-literal=LOGS_HOST=$LOGS_HOST.monitoring.svc.cluster.local \
                                     -n backend \
                                     -o yaml \
                                     --dry-run=client | $KUBECTL_CMD apply -f -
}

function applyFrontendSecrets() {
  $KUBECTL_CMD create secret generic nginx \
                                     --from-literal=BACKEND_HOST=$BACKEND_HOST.backend.svc.cluster.local \
                                     --from-literal=METRICS_HOST=$METRICS_HOST.monitoring.svc.cluster.local \
                                     --from-literal=TRACES_HOST=$TRACES_HOST.monitoring.svc.cluster.local \
                                     --from-literal=LOGS_HOST=$LOGS_HOST.monitoring.svc.cluster.local \
                                     -n frontend \
                                     -o yaml \
                                     --dry-run=client | $KUBECTL_CMD apply -f -
}

function applySecrets() {
  applyDatabaseSecrets
  applyBackendSecrets
  applyFrontendSecrets
}

function main () {
  checkDependencies
  applySecrets
}

main
