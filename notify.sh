#!/bin/bash

function checkDependencies() {
  if [ -z "$CURL_CMD" ]; then
    echo "curl is not installed! Please install it first to continue!"

    exit 1
  fi

  export STATUS=$1

  if [ -z "$STATUS" ]; then
    echo "Status is not defined!"

    exit 1
  fi
}

function prepareToExecute() {
  source functions.sh
}

function notify() {
  URL=https://hooks.slack.com/services/$SLACK_TOKEN

  $CURL_CMD -X POST \
            -H 'Content-type: application/json' \
            --data "{
  \"blocks\": [
    {
      \"type\": \"section\",
      \"text\": {
        \"type\": \"mrkdwn\",
        \"text\": \"*Hi!* The pipeline execution is complete with the status *$STATUS*\"
      }
    },
    {
      \"type\": \"divider\"
    },
    {
      \"type\": \"section\",
      \"text\": {
        \"type\": \"mrkdwn\",
        \"text\": \"Click the button to check the details!\"
      },
      \"accessory\": {
        \"type\": \"button\",
        \"text\": {
          \"type\": \"plain_text\",
          \"text\": \"Learn More\"
        },
        \"url\": \"https://git.vila.app.br/fvilarin/phonebook/actions\"
      }
    }
  ]
}" "$URL"
}

function main() {
  prepareToExecute
  checkDependencies "$1"
  notify
}

main "$1"


