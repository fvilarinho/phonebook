#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$DOCKER_CMD" ]; then
    echo "docker is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner

  cd iac || exit 1
}

# Starts the stack locally.
function start() {
  $DOCKER_CMD compose up -d
}

# Main function.
function main () {
  prepareToExecute
  checkDependencies
  start
}

main