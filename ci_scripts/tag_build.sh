#!/bin/bash
VERSION_FILE=${PWD}/Sources/Trigger/version.swift
CONTENTS=$(<$VERSION_FILE)
APP_VERSION=$(echo $CONTENTS| cut -d'"' -f 2)
echo App version is $APP_VERSION

git tag $APP_VERSION

echo ":> Build was tagged."