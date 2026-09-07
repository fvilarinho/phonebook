#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ ! -e "$JAVA_CMD" ]; then
    echo "java is not installed! Please install it first to continue!"

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

# Starts the build process.
function build() {
  generateCredentials
  generateCertificate

  ./gradlew build -x test
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  build
}

main