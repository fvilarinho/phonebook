#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$CURL_CMD" ]; then
    echo "curl is not installed! Please install it first to continue!"

    exit 1
  fi

  MESSAGE=$1

  if [ -z "$MESSAGE" ]; then
    echo "The message is not defined!"
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh
}

# Notifies the channel.
function notify() {
  URL="https://hooks.slack.com/services/$SLACK_TOKEN"

  $CURL_CMD -s \
            -o /dev/null \
            -X POST \
            -H "Content-type: application/json" \
            --data "{\"text\": \"$MESSAGE\"}" \
            "$URL"
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies "$1"
  notify
}

main "$1"