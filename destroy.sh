#!/usr/bin/env bash

# Checks the dependencies to run this script.
function checkDependencies() {
    if [ -z "$TERRAFORM_CMD" ]; then
        echo "terraform is not installed! Please install it first to continue!"

        exit 1
    fi
}

# Prepares the environment to run this script.
function prepareToExecute() {
    source ./functions.sh

    cd ./iac || exit 1
}

# Destroy the provisioned resources.
function destroy() {
    $TERRAFORM_CMD destroy -auto-approve
}

# Main function.
function main() {
    prepareToExecute
    checkDependencies
    destroy
}

main