#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ ! -e "$CURL_CMD" ]; then
    echo "curl is not installed! Please install it first to continue!"

    exit 1
  fi

  export STATUS=$1

  if [ -z "$STATUS" ]; then
    echo "Status is not defined!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh
}

# Send a message to the notification service.
function notify() {
  URL="https://hooks.slack.com/services/$SLACK_TOKEN"

  if [ "$STATUS" == "success" ]; then
    MESSAGE="Hi there!\n\nGreat news :tada: :smiley:!\n\nThe pipeline execution was *FLAWLESS*! Good job :heart:!"
  else
    MESSAGE="Hi!\n\nI got some bad news :sob:!\n\nThe pipeline execution *FAILED* in some steps!"
  fi

  $CURL_CMD -s \
            -o /dev/null \
            -X POST \
            -H 'Content-type: application/json' \
            --data "{
  \"blocks\": [
    {
      \"type\": \"section\",
      \"text\": {
        \"type\": \"mrkdwn\",
        \"text\": \"$MESSAGE\"
      }
    }
  ]
}" "$URL"
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies "$1" "$2"
  notify
}

main "$1" "$2"


