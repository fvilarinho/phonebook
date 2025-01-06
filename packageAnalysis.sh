#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$SNYK_CMD" ]; then
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
  $SNYK_CMD container test "$DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/phonebook:$BUILD_VERSION" \
                      --file=./Dockerfile \
                      --severity-threshold=high
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  packageAnalysis
}

main