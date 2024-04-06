#!/bin/bash

function checkDependencies() {
  if [ -z "$TERRAFORM_CMD" ]; then
    echo "terraform is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$DOCKER_CMD" ]; then
    echo "docker is not installed! Please install it first to continue!"

    exit 1
  fi
}

function prepareToExecute() {
  source functions.sh

  showBanner
}

function stop() {
  $DOCKER_CMD compose down
}

function cleanUp() {
  $DOCKER_CMD volume prune --force

  VOLUMES=$(docker volume ls -q)

  if [ -n "$VOLUME" ]; then
    $DOCKER_CMD volume rm "$VOLUMES"
  fi
}

function main() {
  prepareToExecute
  checkDependencies
  stop
  cleanUp
}

main