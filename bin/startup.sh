#!/bin/bash

# Show banner.
if [ -e "$ETC_DIR/banner.txt" ]; then
  cat "$ETC_DIR/banner.txt"
fi

# Build the startup script.
JAVA_CMD=$(which java)

STARTUP_OPTS=

if [ "$DEBUG_ENABLED" == true ]; then
  STARTUP_OPTS="$STARTUP_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000"
fi

if [ "$OBSERVABILITY_ENABLED" == true ]; then
  STARTUP_OPTS="$STARTUP_OPTS -Dlogging.config=file:$ETC_DIR/logback.xml"
fi

STARTUP_CMD="$JAVA_CMD $STARTUP_OPTS -jar $LIBS_DIR/$BUILD_NAME.jar"

# Execute the startup script.
eval "$STARTUP_CMD"