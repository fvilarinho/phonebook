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

  if [ "$STATUS" == "success" ]; then
    SUCCESS="Great news :smiley! The pipeline execution was <span style="color:green">*flawless*</span>! Good job :heart:!"
  else
    MESSAGE="I got bad news :sob:! The pipeline execution <span style="color:red">*failed*</span> in some steps!"
  fi

  if []
  MESSAGE=


  $CURL_CMD -X POST \
            -H 'Content-type: application/json' \
            --data "{
  \"blocks\": [
    {
      \"type\": \"section\",
      \"text\": {
        \"type\": \"mrkdwn\",
        \"text\": \"$MESSAGE\"
      }
    },
    {
      \"type\": \"divider\"
    },
    {
      \"type\": \"section\",
      \"text\": {
        \"type\": \"mrkdwn\",
        \"text\": \"Pipeline Execution\"
      },
      \"accessory\": {
        \"type\": \"button\",
        \"text\": {
          \"type\": \"plain_text\",
          \"text\": \"Details\"
        },
        \"url\": \"https://git.vila.app.br/fvilarin/phonebook/actions\"
      }
    },
    {
      \"type\": \"section\",
      \"text\": {
        \"type\": \"mrkdwn\",
        \"text\": \"Code Quality!\"
      },
      \"accessory\": {
        \"type\": \"button\",
        \"text\": {
          \"type\": \"plain_text\",
          \"text\": \"Details\"
        },
        \"url\": \"https://codequality.vila.app.br/dashboard?id=phonebook\"
      }
    },
    {
      \"type\": \"section\",
      \"text\": {
        \"type\": \"mrkdwn\",
        \"text\": \"Tests Reports!\"
      },
      \"accessory\": {
        \"type\": \"button\",
        \"text\": {
          \"type\": \"plain_text\",
          \"text\": \"Details\"
        },
        \"url\": \"https://codequality.vila.app.br/reports/phonebook\"
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


