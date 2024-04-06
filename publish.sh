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

# Authenticates in the container registry.
function auth() {
  echo "$DOCKER_REGISTRY_PASSWORD" | $DOCKER_CMD login -u "$DOCKER_REGISTRY_ID" \
                                                          "$DOCKER_REGISTRY_URL" \
                                                          --password-stdin || exit 1
}

# Publishes the container images.
function publish() {
  $DOCKER_CMD compose push
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  auth
  publish
}

main