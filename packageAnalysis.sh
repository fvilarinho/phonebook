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

  mkdir -p build/packages

  showBanner
}

# Starts the package analysis process.
function packageAnalysis() {
  $DOCKER_CMD save -o "build/packages/$BUILD_NAME.tar" "${DOCKER_REGISTRY_URL}/${DOCKER_REGISTRY_ID}/${BUILD_NAME}:${BUILD_VERSION}" || exit 1

  $SNYK_CMD container test oci-archive:"build/packages/$BUILD_NAME.tar" \
                      --file=./Dockerfile \
                      --severity-threshold=critical || exit 1

  cleanUp
}

function cleanUp() {
  rm -rf build/packages
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  packageAnalysis
}

main