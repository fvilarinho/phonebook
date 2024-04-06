#!/bin/bash

# Environment variables.
JAVA_CMD=$(which java)

# Start command.
$JAVA_CMD -javaagent:"$LIBS_DIR"/opentelemetry-javaagent.jar \
          -jar "$LIBS_DIR"/phonebook.jar