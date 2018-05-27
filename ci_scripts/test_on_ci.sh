#!/bin/bash

# This script provides a way of running the project's unit test
# in a docker container. It particularly pertains to 
# developers working on non-linux platforms locally, 
# and continuous integration
set -e

if [[ $PLATFORM == 'linux' ]]; then
  VERSION_FILE=${PWD}/Sources/Trigger/version.swift
  CONTENTS=$(<$VERSION_FILE)
  APP_VERSION=$(echo $CONTENTS| cut -d'"' -f 2)
  echo App version is $APP_VERSION
  docker build -t compile-swift-on-linux .

  docker run -i --rm -v ${PWD}/linux-test:/artifact compile-swift-on-linux /bin/bash << COMMANDS
  swift test
COMMANDS
else
  swift test
fi
  
  
