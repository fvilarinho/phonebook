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

# Stops the stack locally.
function stop() {
  $DOCKER_CMD compose down
}

# Clean-up (Removes persistent volumes).
function cleanUp() {
  $DOCKER_CMD volume prune --force

  VOLUMES=$(docker volume ls -q)

  if [ -n "$VOLUME" ]; then
    $DOCKER_CMD volume rm "$VOLUMES"
  fi
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  stop
  cleanUp
}

main