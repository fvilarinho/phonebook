#!/bin/bash

# Show banner.
if [ -e "$ETC_DIR/banner.txt" ]; then
  cat "$ETC_DIR/banner.txt"
fi

# Build the startup script.
JAVA_CMD=$(which java)

STARTUP_CMD="$JAVA_CMD"

if [ "$OBSERVABILITY_ENABLED" == "true" ]; then
  export OTEL_EXPORTER_OTLP_ENDPOINT=http://${TRACES_HOST}:4318

  STARTUP_CMD="$STARTUP_CMD -javaagent:$LIBS_DIR/opentelemetry-javaagent.jar"
fi

if [ -e "$ETC_DIR"/logback.xml ]; then
  STARTUP_CMD="$STARTUP_CMD -Dlogging.config=$ETC_DIR/logback.xml"
fi

STARTUP_CMD="$STARTUP_CMD -jar $LIBS_DIR/phonebook.jar"

# Execute the startup script.
eval $STARTUP_CMD