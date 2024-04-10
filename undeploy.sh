#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$TERRAFORM_CMD" ]; then
    echo "terraform is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner

  cd iac || exit 1
}

# Destroys the provisioned infrastructure in Akamai Connected Cloud based on the IaC files.
function deploy() {
  $TERRAFORM_CMD init \
                 -upgrade \
                 -migrate-state || exit 1

  $TERRAFORM_CMD destroy \
                 -auto-approve
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  deploy
}

main