#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ ! -e "$CURL_CMD" ]; then
    echo "curl is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ ! -e "$JQ_CMD" ]; then
    echo "jq is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ ! -e "$JAVA_CMD" ]; then
    echo "java is not installed! Please install it first to continue!"

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

  showBanner
}

# Starts the code analysis process.
function codeAnalysis() {
  ./gradlew sonar || exit 1

  QUALITY_GATE_STATUS=$($CURL_CMD -s \
                                  -H "Authorization: Bearer $SONAR_TOKEN" \
                                  "$SONAR_URL/api/qualitygates/project_status?projectKey=$SONAR_PROJECT_KEY" | $JQ_CMD -r '.projectStatus.status')

  if [ "$QUALITY_GATE_STATUS" == "ERROR" ]; then
    echo
    echo "Code analysis failed! Please check your quality gates!"

    exit 1
  fi
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  codeAnalysis
}

main