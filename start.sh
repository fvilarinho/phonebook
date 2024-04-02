#!/bin/bash

DOCKER_CMD=$(which docker)

source .env

$DOCKER_CMD compose up