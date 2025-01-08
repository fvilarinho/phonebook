#!/bin/bash

function checkDependencies() {
  if [ -z "$KUBECONFIG" ]; then
    echo "kubeconfig is not defined!"

    exit 1
  fi

  if [ -z "$MANIFEST_FILENAME" ]; then
    echo "The manifest file is not defined!"

    exit 1
  fi
}

function applyManifest() {
  $KUBECTL_CMD apply -f "$MANIFEST_FILENAME"
}

function main () {
  checkDependencies
  applyManifest
}

main
