#!/bin/bash
PROJECT_NAME=Conferences
PROJECT_DIR=$(pwd)/$PROJECT_NAME
INFOPLIST_FILE="Info.plist"
CFBundleVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${PROJECT_DIR}/${INFOPLIST_FILE}")
CFBundleShortVersionString=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${PROJECT_DIR}/${INFOPLIST_FILE}")
rm -rf Archive/*
rm -rf Product/*
xcodebuild clean -project $PROJECT_NAME.xcodeproj -configuration Release -alltargets
xcodebuild archive -project $PROJECT_NAME.xcodeproj -scheme $PROJECT_NAME -archivePath Archive/$PROJECT_NAME.xcarchive
xcodebuild -exportArchive -archivePath Archive/$PROJECT_NAME.xcarchive -exportPath Product/$PROJECT_NAME.app -exportFormat app
zip -r "Product/$PROJECT_NAME.v${CFBundleShortVersionString}.b${CFBundleVersion}.zip" Product/$PROJECT_NAME.app