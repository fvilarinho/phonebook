#!/bin/bash

# Check the dependencies of this script.
function checkDependencies(){
  if [ ! -e "$TERRAFORM_CMD" ]; then
    echo "terraform is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ ! -e "$JQ_CMD" ]; then
    echo "jq is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ ! -e "$HTPASSWD_CMD" ]; then
    echo "htpasswd is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner

  cd iac || exit 1
}

function cleanUp() {
  rm -f /tmp/phonebook.tfplan
}

function deploy() {
  $TERRAFORM_CMD init \
                 -upgrade \
                 -migrate-state || exit 1

  $TERRAFORM_CMD plan \
                 -out /tmp/phonebook.tfplan || exit 1

  $TERRAFORM_CMD apply /tmp/phonebook.tfplan || exit 1

  cleanUp
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  deploy
}

main