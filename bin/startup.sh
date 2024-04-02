#!/bin/bash

JAVA_CMD=$(which java)

$JAVA_CMD -javaagent:"$LIBS_DIR"/opentelemetry-javaagent.jar \
          -jar "$LIBS_DIR"/phonebook.jar