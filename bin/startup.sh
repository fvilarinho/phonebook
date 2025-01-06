#!/bin/bash

# Environment variables.
JAVA_CMD=$(which java)

# Startup command.
if [ "$OTEL_ENABLED" == "true" ]; then
  $JAVA_CMD -javaagent:"$LIBS_DIR"/opentelemetry-javaagent.jar \
            -jar "$LIBS_DIR"/phonebook.jar
else
  $JAVA_CMD -jar "$LIBS_DIR"/phonebook.jar
fi


