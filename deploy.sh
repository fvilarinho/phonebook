#!/usr/bin/env bash

# Checks the dependencies to run this script.
function checkDependencies() {
    if [ -z "$TERRAFORM_CMD" ]; then
        echo "terraform is not installed! Please install it first to continue!"

        exit 1
    fi

    if [ -z "${AWS_REGION:-}" ]; then
        echo "AWS_REGION must be set in .secrets before deployment."

        exit 1
    fi
}

# Prepares the environment to run this script.
function prepareToExecute() {
    source ./functions.sh

    cd ./iac || exit 1
}

# Provision the resources.
function deploy() {
    $TERRAFORM_CMD init -migrate-state \
                        -upgrade \
                        -force-copy \
                        -backend-config="bucket=$TERRAFORM_S3_BACKEND_STATE_BUCKET" \
                        -backend-config="key=$TERRAFORM_S3_BACKEND_STATE_KEY" \
                        -backend-config="region=$AWS_REGION" || exit 1

    $TERRAFORM_CMD plan -out="$TMPDIR"/phonebook.tfplan || exit 1
    $TERRAFORM_CMD apply "$TMPDIR"/phonebook.tfplan

    rm -f "$TMPDIR"/phonebook.tfplan
}

# Main function.
function main() {
    prepareToExecute
    checkDependencies
    deploy
}

main