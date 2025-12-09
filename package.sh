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

# Creates the container images.
function package() {
  mkdir -p build/packages || exit 1

  ANALYSIS_PACKAGE_NAME="build/packages/$APP_NAME.oci"

  $DOCKER_CMD buildx build \
                     --platform linux/amd64,linux/arm64 \
                     --tag "$DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/$APP_NAME:$BUILD_VERSION" \
                     .

  if [ -f "$ANALYSIS_PACKAGE_NAME" ]; then
    exit 0
  fi
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  package
}

main