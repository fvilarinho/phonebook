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
  $DOCKER_CMD buildx build \
                     --platform linux/amd64,linux/arm64 \
                     --tag "$DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/$APP_NAME:$BUILD_VERSION" \
                     .

  IMAGE_EXISTS=$($DOCKER_CMD image ls | grep "$DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/$APP_NAME")

  if [ -n "$IMAGE_EXISTS" ]; then
    mkdir -p build/packages

    $DOCKER_CMD save -o "build/packages/$APP_NAME.tar" "$DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/$APP_NAME:$BUILD_VERSION" || exit 1
  fi
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  package
}

main