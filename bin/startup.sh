#!/bin/bash

# Show banner.
if [ -e "$ETC_DIR/banner.txt" ]; then
  cat "$ETC_DIR/banner.txt"
fi

# Environment variables.
JAVA_CMD=$(which java)

# Startup command.
if [ "$OTEL_ENABLED" == "true" ]; then
  $JAVA_CMD -javaagent:"$LIBS_DIR"/opentelemetry-javaagent.jar \
            -jar "$LIBS_DIR"/phonebook.jar
else
  $JAVA_CMD -jar "$LIBS_DIR"/phonebook.jar
fi


