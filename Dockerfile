# Base image defintopn.
FROM alpine:3.20.3

# Matadata definition.
LABEL authors="fvilarinho@gmail.com"

# OS environment variables.
ENV HOME_DIR=/home/phonebook
ENV BIN_DIR=${HOME_DIR}/bin
ENV ETC_DIR=${HOME_DIR}/etc
ENV LIBS_DIR=${HOME_DIR}/libs
ENV LOGS_DIR=${HOME_DIR}/logs

# Database environment variables.
ENV DB_HOST=database
ENV DB_NAME=phonebook
ENV DB_USER=demo
ENV DB_PASS=demo

# Application environment variables.
ENV APP_USER=demo
ENV APP_PASS=demo

# OpenTelemetry environment variables.
ENV OTEL_SERVICE_NAME=phonebook
ENV OTEL_METRICS_EXPORTER=prometheus
ENV OTEL_EXPORTER_PROMETHEUS_PORT=9102
ENV OTEL_EXPORTER_PROMETHEUS_HOST=0.0.0.0
ENV OTEL_TRACES_EXPORTER=otlp
ENV OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://jaeger:4317
ENV OTEL_LOGS_EXPORTER=none

# Creates the directory structure.
RUN mkdir -p ${HOME_DIR} ${BIN_DIR} ${ETC_DIR} ${LIBS_DIR} ${LOGS_DIR}

# Installs all required software.
RUN apk update && \
    apk add --no-cache bash ca-certificates wget curl unzip vim net-tools bind-tools openjdk

# Copies all binaries, libraries and scripts.
COPY bin/*.sh ${BIN_DIR}/
COPY build/libs/phonebook.jar ${LIBS_DIR}/
COPY libs/opentelemetry-javaagent.jar ${LIBS_DIR}/

# Gives the execution permission.
RUN chmod +X ${BIN_DIR}/*.sh && \
    ln -s ${BIN_DIR}/startup.sh /entrypoint.sh

# Entrypoint definition.
ENTRYPOINT ["/entrypoint.sh"]
