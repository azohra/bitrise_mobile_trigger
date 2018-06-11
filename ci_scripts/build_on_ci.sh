#!/bin/bash

# This script provides a way of building the project
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

  docker run -i --rm -v ${PWD}/linux-release:/artifact compile-swift-on-linux /bin/bash << COMMANDS
  set -e
  swift build -c release
  echo copying from .build/release to /artifact in container
  cp .build/release/bitriseTrigger /artifact/bitriseTrigger_linux
COMMANDS
else
  swift build --static-swift-stdlib -c release
  cp .build/release/bitriseTrigger .build/release/bitriseTrigger_osx
fi
echo ":> Build Complete"