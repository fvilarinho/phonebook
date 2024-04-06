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

function package() {
  $DOCKER_CMD compose build
}

function main() {
  prepareToExecute
  checkDependencies
  package
}

main