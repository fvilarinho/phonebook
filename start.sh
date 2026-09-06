#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ ! -e "$DOCKER_CMD" ]; then
    echo "docker is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Prepares the environment to execute this script.
function prepareToExecute() {
  source functions.sh

  showBanner
}

# Creates the credentials of the UI.
function generateCredentials() {
  CREDENTIALS_FILENAME=etc/.htpasswd

  if [ ! -e "$CREDENTIALS_FILENAME" ]; then
    echo "Generating frontend credentials..."

    $HTPASSWD_CMD -cbB etc/.htpasswd "$FRONTEND_USER" "$FRONTEND_PASS" || exit 1
  fi
}

# Creates the TLS certificate for the UI.
function generateCertificate() {
  mkdir -p etc/tls/certs \
           etc/tls/private

  CERTIFICATE_FILENAME=etc/tls/certs/fullchain.pem
  CERTIFICATE_KEY_FILENAME=etc/tls/private/privkey.pem

  if [ -z "$CERTIFICATE" ] || [ -z "$CERTIFICATE_KEY" ]; then
    if [ ! -e "$CERTIFICATE_FILENAME" ] || [ ! -e "$CERTIFICATE_KEY_FILENAME" ]; then
      echo "Generating frontend TLS certificate..."

      $OPENSSL_CMD req -x509 \
                   -newkey rsa:4096 \
                   -keyout $CERTIFICATE_KEY_FILENAME \
                   -out $CERTIFICATE_FILENAME \
                   -days 365 \
                   -nodes \
                   -subj "/CN=$BUILD_NAME.$FRONTEND_DOMAIN" || exit 1
    fi
  else
    echo "$CERTIFICATE" > "$CERTIFICATE_FILENAME" || exit 1
    echo "$CERTIFICATE_KEY" > "$CERTIFICATE_KEY_FILENAME" || exit 1
  fi
}

# Authenticates in the container registry.
function auth() {
  echo "$DOCKER_REGISTRY_PASSWORD" | $DOCKER_CMD login -u "$DOCKER_REGISTRY_ID" \
                                                          "$DOCKER_REGISTRY_URL" \
                                                          --password-stdin || exit 1
}

# Starts the stack locally.
function start() {
  generateCertificate
  generateCredentials
  auth

  $DOCKER_CMD compose up -d
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  start
}

main