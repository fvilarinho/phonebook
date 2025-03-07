#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$CURL_CMD" ]; then
    echo "curl is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$JQ_CMD" ]; then
    echo "jq is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$JAVA_CMD" ]; then
    echo "java is not installed! Please install it first to continue!"

    exit 1
  fi

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

# Starts the code analysis process.
function codeAnalysis() {
  ./gradlew sonar || exit 1

  echo "$CURL_CMD -s -u \"$SONAR_USER:$SONAR_PASSWORD\" \"$SONAR_URL\"/api/qualitygates/project_status?projectKey=\"$SONAR_PROJECT_KEY\""

  #| $JQ_CMD -r '.projectStatus.status')

  #if [ "$QUALITY_GATE_STATUS" == "ERROR" ]; then
  #  echo
  #  echo "Code analysis failed! Please check your quality gates!"

  #  exit 1
  #fi

  $SNYK_CMD code test --severity-threshold=high
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  codeAnalysis
}

main