#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$CERTIFICATE" ] || [ -z "$CERTIFICATE_KEY" ]; then
    if [ -z "$CERTBOT_CMD" ]; then
      echo "certbot is not installed! Please install it first to continue!"

      exit 1
    fi

    HAS_DNS_LINODE_PLUGIN=$($CERTBOT_CMD plugins | grep dns-linode)

    if [ -z "$HAS_DNS_LINODE_PLUGIN" ]; then
      echo "certbot dns-linode plugin is not installed! Please install it first to continue!"

      exit 1
    fi
  fi

  if [ -z "$HTPASSWD_CMD" ]; then
    echo "htpasswd is not installed! Please install it first to continue!"

    exit 1
  fi
}

# Creates the credentials of the UI.
function generateCredentials() {
  $HTPASSWD_CMD -cbB ../etc/.htpasswd "$APP_USER" "$APP_PASS" || exit 1
}

# Creates the TLS certificate for the UI.
function generateCertificate() {
  mkdir -p ../etc/tls/certs \
           ../etc/tls/private

  if [ -z "$CERTIFICATE" ] || [ -z "$CERTIFICATE_KEY" ]; then
    CERTIFICATE_FILENAME="/etc/letsencrypt/live/$APP_NAME.$APP_DOMAIN/fullchain.pem"
    CERTIFICATE_KEY_FILENAME="/etc/letsencrypt/live/$APP_NAME.$APP_DOMAIN/privkey.pem"

    if [ ! -e "$CERTIFICATE_FILENAME" ] || [ ! -e "$CERTIFICATE_KEY_FILENAME" ]; then
      CERTIFICATE_VALIDATION_CREDENTIALS=/tmp/.certbotValidation.credentials

      echo "dns_linode_key = $LINODE_TOKEN" > $CERTIFICATE_VALIDATION_CREDENTIALS

      chmod og-rwx $CERTIFICATE_VALIDATION_CREDENTIALS || exit 1

      $CERTBOT_CMD certonly \
                   --dns-linode \
                   --dns-linode-credentials "$CERTIFICATE_VALIDATION_CREDENTIALS" \
                   -d "$APP_NAME.$APP_DOMAIN" \
                   -m "$APP_EMAIL" \
                   --agree-tos \
                   -n || exit 1

      rm -f $CERTIFICATE_VALIDATION_CREDENTIALS
    fi

    if [ -e "$CERTIFICATE_FILENAME" ]; then
      cp -f "$CERTIFICATE_FILENAME" ../etc/tls/certs || exit 1

      if [ -e "$CERTIFICATE_KEY_FILENAME" ]; then
        cp -f "$CERTIFICATE_KEY_FILENAME" ../etc/tls/private || exit 1
      fi
    fi
  else
    echo "$CERTIFICATE" > ../etc/tls/certs/fullchain.pem || exit 1
    echo "$CERTIFICATE_KEY" > ../etc/tls/private/privkey.pem || exit 1
  fi
}

# Main function.
function main() {
  checkDependencies
  generateCertificate
  generateCredentials
}

main