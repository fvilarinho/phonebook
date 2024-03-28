#!/bin/bash

export DB_HOST=db.vila.app.br

export OTEL_TRACES_EXPORTER=none
export OTEL_LOGS_EXPORTER=none

java -javaagent:../libs/opentelemetry-javaagent.jar -jar ../build/libs/phonebook.jar

