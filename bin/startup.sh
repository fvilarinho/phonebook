#!/bin/bash

# Show banner.
if [ -e "$ETC_DIR/banner.txt" ]; then
  cat "$ETC_DIR/banner.txt"
fi

# Build the startup script.
JAVA_CMD=$(which java)

STARTUP_CMD="$JAVA_CMD -jar $LIBS_DIR/phonebook.jar"

# Execute the startup script.
eval "$STARTUP_CMD"