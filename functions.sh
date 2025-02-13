#!/bin/bash

# Shows the labels.
function showLabel() {
  if [[ "$0" == *"build.sh"* ]]; then
    echo "** BUILD **"
  elif [[ "$0" == *"codeAnalysis.sh"* ]]; then
    echo "** CODE ANALYSIS **"
  elif [[ "$0" == *"librariesAnalysis.sh"* ]]; then
    echo "** LIBRARIES ANALYSIS **"
  elif [[ "$0" == *"packageAnalysis.sh"* ]]; then
    echo "** PACKAGE ANALYSIS **"
  elif [[ "$0" == *"package.sh"* ]]; then
      echo "** PACKAGING **"
  elif [[ "$0" == *"publish.sh"* ]]; then
    echo "** PUBLISHING **"
  elif [[ "$0" == *"start.sh"* ]]; then
    echo "** START **"
  elif [[ "$0" == *"stop.sh"* ]]; then
    echo "** STOP **"
  elif [[ "$0" == *"deploy.sh"* ]]; then
    echo "** DEPLOY **"
  fi
}

# Shows the banner.
function showBanner() {
  if [ -e "banner.txt" ]; then
    cat banner.txt
  fi

  showLabel
}

# Prepares the environment to execute the commands of this script.
function prepareToExecute() {
  # Required files/paths.
  export WORK_DIR="$PWD"
  export ENV_FILENAME="$WORK_DIR/.env"

  # Environment variables.
  if [ -f "$ENV_FILENAME" ]; then
    source "$ENV_FILENAME"
  else
    if [ -n "$BUILD_DEFINITIONS" ]; then
      echo "$BUILD_DEFINITIONS" > "$ENV_FILENAME"

      source "$ENV_FILENAME"
    fi
  fi

  # Required binaries.
  export CERTBOT_CMD=$(which certbot)
  export HTPASSWD_CMD=$(which htpasswd)
  export CURL_CMD=$(which curl)
  export JQ_CMD=$(which jq)
  export JAVA_CMD=$(which java)
  export SNYK_CMD=$(which snyk)
  export DOCKER_CMD=$(which docker)
  export TERRAFORM_CMD=$(which terraform)
}

prepareToExecute