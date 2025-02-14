#!/bin/bash

# Check the dependencies of this script.
function checkDependencies(){
  if [ -z "$TERRAFORM_CMD" ]; then
    echo "terraform is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$JQ_CMD" ]; then
    echo "jq is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$HTPASSWD_CMD" ]; then
    echo "htpasswd is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner

  cd iac || exit 1

  if [ -n "$PROVISIONING_DEFINITIONS" ]; then
    echo "$PROVISIONING_DEFINITIONS" > terraform.tfvars
  fi

  if [ -n "$SSH_PRIVATE_KEY" ]; then
    mkdir -p ~/.ssh

    echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa

    if [ -n "$SSH_PUBLIC_KEY" ]; then
      echo "$SSH_PUBLIC_KEY" > ~/.ssh/id_rsa.pub
    fi
  fi
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