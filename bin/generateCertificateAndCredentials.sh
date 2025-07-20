#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ ! -e "$OPENSSL_CMD" ]; then
    echo "openssl is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ ! -e "$HTPASSWD_CMD" ]; then
    echo "htpasswd is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Creates the credentials of the UI.
function generateCredentials() {
  CREDENTIALS_FILENAME=etc/.htpasswd

  if [ ! -e "$CREDENTIALS_FILENAME" ]; then
    echo "Generating the application credentials..."

    $HTPASSWD_CMD -cbB etc/.htpasswd "$APP_USER" "$APP_PASS" || exit 1
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
      echo "Generating TLS certificate..."

      $OPENSSL_CMD req -x509 \
                   -newkey rsa:4096 \
                   -keyout $CERTIFICATE_KEY_FILENAME \
                   -out $CERTIFICATE_FILENAME \
                   -days 365 \
                   -nodes \
                   -subj "/CN=$APP_NAME.$APP_DOMAIN" || exit 1
    fi
  else
    echo "$CERTIFICATE" > "$CERTIFICATE_FILENAME" || exit 1
    echo "$CERTIFICATE_KEY" > "$CERTIFICATE_KEY_FILENAME" || exit 1
  fi
}

# Main function.
function main() {
  checkDependencies
  generateCertificate
  generateCredentials
}

main