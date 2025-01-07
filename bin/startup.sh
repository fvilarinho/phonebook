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
            -Dlogging.config="$ETC_DIR"/logback-spring.xml \
            -jar "$LIBS_DIR"/phonebook.jar
else
  $JAVA_CMD -Dlogging.config="$ETC_DIR"/logback-spring.xml \
            -jar "$LIBS_DIR"/phonebook.jar
fi


