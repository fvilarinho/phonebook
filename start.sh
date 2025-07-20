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

# Authenticates in the container registry.
function auth() {
  echo "$DOCKER_REGISTRY_PASSWORD" | $DOCKER_CMD login -u "$DOCKER_REGISTRY_ID" \
                                                          "$DOCKER_REGISTRY_URL" \
                                                          --password-stdin || exit 1
}

# Starts the stack locally.
function start() {
  generateCertificateAndCredentials
  auth

  $DOCKER_CMD compose pull || exit 1
  $DOCKER_CMD compose up -d
}

# Ensures the certificate and credentials exist.
function generateCertificateAndCredentials() {
  GENERATE_CERTIFICATE_AND_CREDENTIALS_SCRIPT_FILENAME=bin/generateCertificateAndCredentials.sh

  if [ -e "$GENERATE_CERTIFICATE_AND_CREDENTIALS_SCRIPT_FILENAME" ]; then
    eval "$GENERATE_CERTIFICATE_AND_CREDENTIALS_SCRIPT_FILENAME" || exit 1
  fi
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  start
}

main