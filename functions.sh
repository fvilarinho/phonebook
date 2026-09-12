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
  fi
}

# Shows the banner.
function showBanner() {
  if [ -e "banner.txt" ]; then
    cat banner.txt
  fi

  showLabel
}

function getAttribute() {
  local response=

  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "$response"
  else
    response=$($JQ_CMD -r ".$1" "$2")

    if [ "$response" = "null" ]; then
      response=
    fi

    echo "$response"
  fi
}

function loadBuildAttributes() {
  if [ -f "$BUILD_FILENAME" ]; then
    export BUILD_NAME=$(getAttribute "name" "$BUILD_FILENAME")
    export BUILD_VERSION=$(getAttribute "version" "$BUILD_FILENAME")
  fi
}

function loadSecretsAttributes() {
  if [ ! -f "$SECRETS_FILENAME" ]; then
    if [ -n "$SECRETS" ]; then
      echo "$SECRETS" > "$SECRETS_FILENAME"
    fi
  fi

  if [ -f "$SECRETS_FILENAME" ]; then
    export SONAR_TOKEN=$(getAttribute "sonar.token" "$SECRETS_FILENAME")
    export SONAR_URL=$(getAttribute "sonar.url" "$SECRETS_FILENAME")
    export SONAR_ORGANIZATION=$(getAttribute "sonar.organization" "$SECRETS_FILENAME")
    export SONAR_PROJECT_KEY=$(getAttribute "sonar.project.key" "$SECRETS_FILENAME")

    export SNYK_TOKEN=$(getAttribute "snyk.token" "$SECRETS_FILENAME")

    export SLACK_TOKEN=$(getAttribute "slack.token" "$SECRETS_FILENAME")

    export DOCKER_REGISTRY_URL=$(getAttribute "docker.registry.url" "$SECRETS_FILENAME")
    export DOCKER_REGISTRY_ID=$(getAttribute "docker.registry.id" "$SECRETS_FILENAME")
    export DOCKER_REGISTRY_PASSWORD=$(getAttribute "docker.registry.password" "$SECRETS_FILENAME")

    export TERRAFORM_STATE_BUCKET=$(getAttribute "terraform.state.bucket" "$SECRETS_FILENAME")
    export TERRAFORM_STATE_KEY=$(getAttribute "terraform.state.key" "$SECRETS_FILENAME")

    export AWS_REGION=$(getAttribute "aws.region" "$SECRETS_FILENAME")

    local buffer=$(getAttribute "aws.profile" "$SECRETS_FILENAME")

    if [ -n "$buffer" ]; then
      export AWS_PROFILE=$buffer
    fi

    buffer=$(getAttribute "aws.access_key" "$SECRETS_FILENAME")

    if [ -n "$buffer" ]; then
      export AWS_ACCESS_KEY_ID=$buffer
    fi

    buffer=$(getAttribute "aws.secret_key" "$SECRETS_FILENAME")

    if [ -n "$buffer" ]; then
      export AWS_SECRET_ACCESS_KEY=$buffer
    fi

    export CLOUDFLARE_API_TOKEN=$(getAttribute "cloudflare.token" "$SECRETS_FILENAME")

    export FRONTEND_HOST=$(getAttribute "frontend.host" "$SECRETS_FILENAME")
    export FRONTEND_DOMAIN=$(getAttribute "frontend.domain" "$SECRETS_FILENAME")
    export FRONTEND_USER=$(getAttribute "frontend.user" "$SECRETS_FILENAME")
    export FRONTEND_PASSWORD=$(getAttribute "frontend.password" "$SECRETS_FILENAME")

    export BACKEND_HOST=$(getAttribute "backend.host" "$SECRETS_FILENAME")
    export DEBUG_ENABLED=$(getAttribute "backend.debug.enabled" "$SECRETS_FILENAME")
    export OBSERVABILITY_ENABLED=$(getAttribute "backend.observability.enabled" "$SECRETS_FILENAME")
    export OBSERVABILITY_LOGS_URL=$(getAttribute "backend.observability.logs.url" "$SECRETS_FILENAME")

    export DB_HOST=$(getAttribute "database.host" "$SECRETS_FILENAME")
    export DB_NAME=$(getAttribute "database.name" "$SECRETS_FILENAME")
    export DB_USER=$(getAttribute "database.user" "$SECRETS_FILENAME")
    export DB_PASSWORD=$(getAttribute "database.password" "$SECRETS_FILENAME")
  fi
}

# Prepares the environment to execute the commands of this script.
function prepareToExecute() {
  # Required files/paths.
  export WORK_DIR="$PWD"
  export BUILD_FILENAME="$WORK_DIR/build.json"
  export SECRETS_FILENAME="$WORK_DIR/secrets.json"

  # Required binaries.
  export CURL_CMD=$(which curl 2>/dev/null)
  export JQ_CMD=$(which jq 2>/dev/null)
  export OPENSSL_CMD=$(which openssl 2>/dev/null)
  export HTPASSWD_CMD=$(which htpasswd 2>/dev/null)
  export JAVA_CMD=$(which java 2>/dev/null)
  export SNYK_CMD=$(which snyk 2>/dev/null)
  export DOCKER_CMD=$(which docker 2>/dev/null)
  export TERRAFORM_CMD=$(which terraform 2>/dev/null)

  # Load environment variables.
  loadBuildAttributes
  loadSecretsAttributes
}

prepareToExecute