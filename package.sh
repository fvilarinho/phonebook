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
}

# Creates the container images.
function package() {
  $DOCKER_CMD compose -f stack-build.yml build
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  package
}

main