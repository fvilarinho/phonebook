#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$JAVA_CMD" ]; then
    echo "java is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner
}

# Starts the build process.
function build() {
  ./gradlew build
}

# Main function.
function main() {
  prepareToExecute
  build
}

main