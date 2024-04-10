#!/bin/bash

# Environment variables.
JAVA_CMD=$(which java)

# Start command with the OpenTelemetry agent.
$JAVA_CMD -javaagent:"$LIBS_DIR"/opentelemetry-javaagent.jar \
          -jar "$LIBS_DIR"/phonebook.jar