#!/bin/bash

function checkDependencies() {
  if [ -z "$DOCKER_CMD" ]; then
    echo "docker is not installed! Please install it first to continue!"

    exit 1
  fi
}

function prepareToExecute() {
  source functions.sh

  showBanner
}

function auth() {
  echo "$DOCKER_REGISTRY_PASSWORD" | $DOCKER_CMD login -u "$DOCKER_REGISTRY_ID" \
                                                          "$DOCKER_REGISTRY_URL" \
                                                          --password-stdin || exit 1
}

function publish() {
  $DOCKER_CMD compose push
}

function main() {
  prepareToExecute
  checkDependencies
  auth
  publish
}

main