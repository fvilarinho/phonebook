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
  PACKAGE_NAME="build/packages/$APP_NAME.tar"

  if [ -e "$PACKAGE_NAME" ]; then
    $DOCKER_CMD load -i "$PACKAGE_NAME" || exit 1
  fi

  $SNYK_CMD container test "$DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/$APP_NAME:$BUILD_VERSION" \
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