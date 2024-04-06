#!/bin/bash

function checkDependencies() {
  if [ -z "$TERRAFORM_CMD" ]; then
    echo "terraform is not installed! Please install it first to continue!"

    exit 1
  fi
}

function prepareToExecute() {
  source functions.sh

  showBanner
}

function deploy() {
  $TERRAFORM_CMD init \
                 -upgrade \
                 -migrate-state || exit 1

  $TERRAFORM_CMD apply \
                 -auto-approve
}

function main() {
  prepareToExecute
  checkDependencies
  deploy
}

main