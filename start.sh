#!/bin/bash

function checkDependencies() {
  if [ -z "$TERRAFORM_CMD" ]; then
    echo "terraform is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$DOCKER_CMD" ]; then
    echo "docker is not installed! Please install it first to continue!"

    exit 1
  fi
}

function prepareToExecute() {
  source functions.sh

  showBanner
}

function createCertificate() {
  $TERRAFORM_CMD init \
                 -upgrade \
                 -migrate-state || exit 1

  $TERRAFORM_CMD apply \
                 -target=tls_private_key.default \
                 -target=tls_self_signed_cert.default \
                 -target=local_sensitive_file.certificateKey \
                 -target=local_sensitive_file.certificate \
                 -compact-warnings \
                 -auto-approve
}

function start() {
  $DOCKER_CMD compose up -d
}

function main () {
  prepareToExecute
  checkDependencies
  createCertificate
  start
}

main