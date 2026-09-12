# Base image definition.
FROM alpine:3.24.1

# Metadata definition.
LABEL authors="me@vila.net.br"

# OS environment variables.
ENV BUILD_NAME=phonebook
ENV HOME_DIR=/home/${BUILD_NAME}
ENV BIN_DIR=${HOME_DIR}/bin
ENV ETC_DIR=${HOME_DIR}/etc
ENV LIBS_DIR=${HOME_DIR}/libs
ENV LOGS_DIR=${HOME_DIR}/logs

# Database environment variables.
ENV DB_HOST=database
ENV DB_USER=demo
ENV DB_PASSWORD=demo
ENV DB_NAME=phonebook

# Debug flag.
ENV DEBUG_ENABLED=false

# Creates the directory structure.
RUN mkdir -p ${HOME_DIR} \
             ${BIN_DIR} \
             ${ETC_DIR} \
             ${LIBS_DIR} \
             ${LOGS_DIR}

# Installs all required software.
RUN apk update && \
    apk add --no-cache bash \
                       ca-certificates \
                       wget \
                       curl \
                       unzip \
                       vim \
                       net-tools \
                       bind-tools \
                       openjdk17-jre

# Copies all binaries, libraries and scripts.
COPY banner.txt ${ETC_DIR}/
COPY bin/startup.sh ${BIN_DIR}/
COPY build/libs/phonebook.jar ${LIBS_DIR}/${BUILD_NAME}.jar
COPY etc/logback.xml ${ETC_DIR}/
COPY src/main/resources/wizexercise.txt ${HOME_DIR}/

# Gives the  execution permission.
RUN chmod +x ${BIN_DIR}/*.sh && \
    ln -s ${BIN_DIR}/startup.sh /entrypoint.sh

WORKDIR ${HOME_DIR}

# Entrypoint definition.
ENTRYPOINT ["/entrypoint.sh"]