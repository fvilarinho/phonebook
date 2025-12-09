#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ ! -e "$DOCKER_CMD" ]; then
    echo "docker is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ ! -e "$SNYK_CMD" ]; then
    echo "snyk is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner
}

# Starts the package analysis process.
function packageAnalysis() {
  $SNYK_CMD container test docker-archive:"build/packages/$APP_NAME.tar" \
                      --file=./Dockerfile \
                      --severity-threshold=critical
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  packageAnalysis
}

main