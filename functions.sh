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

function loadBuildAttributes() {
  export BUILD_NAME=$($JQ_CMD -r '.name' "$BUILD_FILENAME")
  export BUILD_VERSION=$($JQ_CMD -r '.version' "$BUILD_FILENAME")
}

function loadSecretsAttributes() {
  if [ ! -f "$SECRETS_FILENAME" ]; then
    if [ -n "$SECRETS" ]; then
      echo "$SECRETS" > "$SECRETS_FILENAME"
    fi
  fi

  if [ -f "$SECRETS_FILENAME" ]; then
    export SONAR_URL=$($JQ_CMD -r '.sonar.url' "$SECRETS_FILENAME")
    export SONAR_ORGANIZATION=$($JQ_CMD -r '.sonar.organization' "$SECRETS_FILENAME")
    export SONAR_PROJECT_KEY=$($JQ_CMD -r '.sonar.projectKey' "$SECRETS_FILENAME")
    export SONAR_TOKEN=$($JQ_CMD -r '.sonar.token' "$SECRETS_FILENAME")

    export SNYK_TOKEN=$($JQ_CMD -r '.snyk.token' "$SECRETS_FILENAME")

    export SLACK_TOKEN=$($JQ_CMD -r '.slack.token' "$SECRETS_FILENAME")

    export DOCKER_REGISTRY_URL=$($JQ_CMD -r '.dockerRegistry.url' "$SECRETS_FILENAME")
    export DOCKER_REGISTRY_ID=$($JQ_CMD -r '.dockerRegistry.id' "$SECRETS_FILENAME")
    export DOCKER_REGISTRY_PASSWORD=$($JQ_CMD -r '.dockerRegistry.password' "$SECRETS_FILENAME")

    export TERRAFORM_STATE_BUCKET=$($JQ_CMD -r '.terraform.state.bucket' "$SECRETS_FILENAME")
    export TERRAFORM_STATE_KEY=$($JQ_CMD -r '.terraform.state.key' "$SECRETS_FILENAME")

    export AWS_PROFILE=$($JQ_CMD -r '.aws.profile' "$SECRETS_FILENAME")
    export AWS_REGION=$($JQ_CMD -r '.aws.region' "$SECRETS_FILENAME")

    export CLOUDFLARE_API_TOKEN=$($JQ_CMD -r '.cloudflare.token' "$SECRETS_FILENAME")

    export FRONTEND_HOST=$($JQ_CMD -r '.frontend.host' "$SECRETS_FILENAME")
    export FRONTEND_DOMAIN=$($JQ_CMD -r '.frontend.domain' "$SECRETS_FILENAME")
    export FRONTEND_USER=$($JQ_CMD -r '.frontend.user' "$SECRETS_FILENAME")
    export FRONTEND_PASSWORD=$($JQ_CMD -r '.frontend.password' "$SECRETS_FILENAME")

    export BACKEND_HOST=$($JQ_CMD -r '.backend.host' "$SECRETS_FILENAME")
    export DEBUG_ENABLED=$($JQ_CMD -r '.backend.debug.enabled' "$SECRETS_FILENAME")
    export OBSERVABILITY_ENABLED=$($JQ_CMD -r '.backend.observability.enabled' "$SECRETS_FILENAME")
    export OBSERVABILITY_LOGS_URL=$($JQ_CMD -r '.backend.observability.logsUrl' "$SECRETS_FILENAME")

    export DB_HOST=$($JQ_CMD -r '.database.host' "$SECRETS_FILENAME")
    export DB_NAME=$($JQ_CMD -r '.database.name' "$SECRETS_FILENAME")
    export DB_USER=$($JQ_CMD -r '.database.user' "$SECRETS_FILENAME")
    export DB_PASSWORD=$($JQ_CMD -r '.database.password' "$SECRETS_FILENAME")
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