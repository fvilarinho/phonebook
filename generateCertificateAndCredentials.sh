#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$CERTBOT_CMD" ]; then
    echo "certbot is not installed! Please install it first to continue!"

    exit 1
  fi

  HAS_DNS_LINODE_PLUGIN=$($CERTBOT_CMD plugins | grep dns-linode)

  if [ -z "$HAS_DNS_LINODE_PLUGIN" ]; then
    echo "certbot dns-linode plugin is not installed! Please install it first to continue!"

    exit 1
  fi

  if [ -z "$HTPASSWD_CMD" ]; then
    echo "htpasswd is not installed! Please install it first to continue!"

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
  $HTPASSWD_CMD -cbB ./etc/.htpasswd "$APP_USER" "$APP_PASS"
}

# Creates the TLS certificate for the UI.
function generateCertificate() {
  CERTIFICATE_FILENAME="/etc/letsencrypt/live/$APP_DOMAIN/fullchain.pem"
  CERTIFICATE_KEY_FILENAME="/etc/letsencrypt/live/$APP_DOMAIN/privkey.pem"

  mkdir -p ./etc/tls/certs ./etc/tls/private

  if [ ! -e "$CERTIFICATE_FILENAME" ] || [ ! -e "$CERTIFICATE_KEY_FILENAME" ]; then
    CERTIFICATE_VALIDATION_CREDENTIALS=/tmp/.certbotValidation.credentials

    echo "dns_linode_key = $LINODE_API_TOKEN" > $CERTIFICATE_VALIDATION_CREDENTIALS

    chmod og-rwx $CERTIFICATE_VALIDATION_CREDENTIALS

    $CERTBOT_CMD certonly \
                 --dns-linode \
                 --dns-linode-credentials "$CERTIFICATE_VALIDATION_CREDENTIALS" \
                 -d "*.$APP_DOMAIN" \
                 -m "$APP_EMAIL" \
                 --agree-tos \
                 -n

    rm -f $CERTIFICATE_VALIDATION_CREDENTIALS
  fi

  if [ -e "$CERTIFICATE_FILENAME" ]; then
    cp -f "$CERTIFICATE_FILENAME" ./etc/tls/certs

    if [ -e "$CERTIFICATE_KEY_FILENAME" ]; then
      cp -f "$CERTIFICATE_KEY_FILENAME" ./etc/tls/private
    fi
  fi
}

# Main function.
function main() {
  prepareToExecute
  checkDependencies
  generateCertificate
  generateCredentials
}

main