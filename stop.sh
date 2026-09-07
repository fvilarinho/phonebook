#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ ! -e "$DOCKER_CMD" ]; then
    echo "docker is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner
}

# Stops the stack locally.
function stop() {
  $DOCKER_CMD compose down --remove-orphans || exit 1
  $DOCKER_CMD volume prune --all --force
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  stop
}

main