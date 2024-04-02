#!/bin/bash

TERRAFORM_CMD=$(which terraform)

$TERRAFORM_CMD init \
               -upgrade \
               -migrate-state || exit 1

$TERRAFORM_CMD plan || exit 1

$TERRAFORM_CMD apply \
               -auto-approve

