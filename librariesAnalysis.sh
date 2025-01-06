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

# Starts the libraries analysis process.
function librariesAnalysis() {
  $SNYK_CMD test --severity-threshold=high || exit
  $SNYK_CMD log4shell
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  librariesAnalysis
}

main