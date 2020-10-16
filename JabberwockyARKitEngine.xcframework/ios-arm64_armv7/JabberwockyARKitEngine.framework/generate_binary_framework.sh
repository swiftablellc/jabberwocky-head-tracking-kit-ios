#!/bin/sh

# Create a new aggregate target.
# For the automatically generated scheme, change its build config to "release".
# Ensure this target's "product name" build setting matches the framework's.
# Add a run script with `source "${PROJECT_DIR}/path_to_this_script`

RELEASE_DIR=${PROJECT_DIR}/../jabberwocky-head-tracking-kit-ios
BUILD_DIR=./build
XC_FRAMEWORK_DIR=${BUILD_DIR}/${PROJECT_NAME}.xcframework

# fail if RELEASE_DIR does not exist
if [ ! -d "$RELEASE_DIR" ]; then
    echo "RELEASE_DIR of $RELEASE_DIR does not exist." ;
    echo "jabberwocky-arkit-engine-ios and jabberwocky-head-tracking-kit-ios must be in the same parent directory."
    exit 1
fi

# Step 1 - Archive iOS and iOS Simulator

xcodebuild archive \
    -workspace JabberwockyARKitEngine.xcworkspace \
    -scheme ${PROJECT_NAME} \
    -configuration release \
    -destination "generic/platform=iOS" \
    -archivePath ${BUILD_DIR}/ios \
    SKIP_INSTALL=NO \
    ENABLE_BITCODE=YES \
    BITCODE_GENERATION_MODE=bitcode \
    OTHER_C_FLAGS=-fembed-bidcode \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
    -workspace JabberwockyARKitEngine.xcworkspace \
    -scheme ${PROJECT_NAME} \
    -configuration release \
    -destination "generic/platform=iOS Simulator" \
    -archivePath ${BUILD_DIR}/sim \
    SKIP_INSTALL=NO \
    ENABLE_BITCODE=YES \
    BITCODE_GENERATION_MODE=bitcode \
    OTHER_C_FLAGS=-fembed-bidcode \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Step 2 - Create XCFramework

rm -rf $XC_FRAMEWORK_DIR

xcodebuild -create-xcframework \
    -framework ${BUILD_DIR}/ios.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework \
    -framework ${BUILD_DIR}/sim.xcarchive/Products/Library/Frameworks/${PROJECT_NAME}.framework \
    -output $XC_FRAMEWORK_DIR

# Step 3 - Add LICENSE to auto-generated Header file

AUTO_GEN_FILE_IOS=$XC_FRAMEWORK_DIR/ios-arm64_armv7/${PROJECT_NAME}.framework/Headers/${PROJECT_NAME}-Swift.h
if [ -r $AUTO_GEN_FILE_IOS ]; then
    echo "Copying License into $AUTO_GEN_FILE_IOS"
else
    echo "error: $AUTO_GEN_FILE_IOS could not be found." ; exit 1
fi
cat ${PROJECT_DIR}/LICENSE-application.txt $AUTO_GEN_FILE_IOS > tempfile && mv tempfile $AUTO_GEN_FILE_IOS

AUTO_GEN_FILE_SIM=$XC_FRAMEWORK_DIR/ios-arm64_i386_x86_64-simulator/${PROJECT_NAME}.framework/Headers/${PROJECT_NAME}-Swift.h
if [ -r $AUTO_GEN_FILE_SIM ]; then
    echo "Copying License into $AUTO_GEN_FILE_SIM"
else
    echo "error: $AUTO_GEN_FILE_SIM could not be found." ; exit 1
fi
cat ${PROJECT_DIR}/LICENSE-application.txt $AUTO_GEN_FILE_SIM > tempfile && mv tempfile $AUTO_GEN_FILE_SIM

# Step 4. Convenience step to copy the framework to the project's directory
echo "Copying $XC_FRAMEWORK_DIR into ${RELEASE_DIR}"
cp -R $XC_FRAMEWORK_DIR ${RELEASE_DIR}
