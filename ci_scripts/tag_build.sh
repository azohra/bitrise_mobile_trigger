#!/bin/bash
# setting exit on error
set -e

VERSION_FILE=${PWD}/Sources/Trigger/version.swift
CONTENTS=$(<$VERSION_FILE)
APP_VERSION=$(echo $CONTENTS| cut -d'"' -f 2)
echo App version is $APP_VERSION

# turning off exit on error
set +e

git tag $APP_VERSION

if [ $? == 0 ]
then 
  echo ":> Build was tagged."
else 
  echo ":> Build was previously tagged."
fi
