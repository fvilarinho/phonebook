#!/usr/bin/env bash

DOCKER_CMD=$(which docker)
AWS_CLI_CMD=$(which aws)

if [ -z "$DOCKER_CMD" ]; then
  echo "docker is not installed! Please install it first to continue!"

  exit 1
fi

if [ -z "$AWS_CLI_CMD" ]; then
  echo "aws cli is not installed! Please install it first to continue!"

  exit 1
fi

if [ -f .env ]; then
  source .env
fi

sudo $DOCKER_CMD exec database mongodump --username $DB_USER --password $DB_PASSWORD || exit 1
sudo $DOCKER_CMD cp database:/dump . || exit 1
sudo chown -R ubuntu:ubuntu dump || exit 1

BACKUP_FILE="backup-$(date +%Y-%m-%d_%H%M%S).zip"

zip -r $BACKUP_FILE dump || exit 1
$AWS_CLI_CMD s3 cp $BACKUP_FILE s3://$BACKUP_BUCKET/$BACKUP_FILE || exit 1

rm -rf dump
rm -f $BACKUP_FILE