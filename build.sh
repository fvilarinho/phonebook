#!/bin/bash

function prepareToExecute() {
  source functions.sh

  showBanner
}

function build() {
  ./gradlew build
}

function main() {
  prepareToExecute
  build
}

main