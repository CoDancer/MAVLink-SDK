#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source ${SCRIPT_DIR}/init_variables.bash

if [ ! -d ${BUILD_DIR}/grpc-swift ]; then
    git -C ${BUILD_DIR} clone -b 0.4.2 https://github.com/grpc/grpc-swift.git
fi

cd ${BUILD_DIR}/grpc-swift
make && make project

xcodebuild -target BoringSSL -target SwiftGRPC -target SwiftProtobuf -target CgRPC -configuration Release -sdk iphoneos IPHONEOS_DEPLOYMENT_TARGET=9.0 CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
xcodebuild -target BoringSSL -target SwiftGRPC -target SwiftProtobuf -target CgRPC -configuration Release -sdk iphonesimulator IPHONEOS_DEPLOYMENT_TARGET=9.0 CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO

# Generate fat binaries
for TARGET_NAME in BoringSSL SwiftGRPC SwiftProtobuf CgRPC; do
    echo "Generating fat binary for ${TARGET_NAME}"
    cp -r ${BUILD_DIR}/grpc-swift/build/Release-iphoneos/${TARGET_NAME}.framework ${BIN_DIR}

    lipo ${BUILD_DIR}/grpc-swift/build/Release-iphoneos/${TARGET_NAME}.framework/${TARGET_NAME} ${BUILD_DIR}/grpc-swift/build/Release-iphonesimulator/${TARGET_NAME}.framework/${TARGET_NAME} -create -output ${BIN_DIR}/${TARGET_NAME}.framework/${TARGET_NAME}

    if [ -d ${BUILD_DIR}/grpc-swift/build/Release-iphonesimulator/${TARGET_NAME}.framework/Modules/${TARGET_NAME}.swiftmodule ]; then
        cp ${BUILD_DIR}/grpc-swift/build/Release-iphonesimulator/${TARGET_NAME}.framework/Modules/${TARGET_NAME}.swiftmodule/* ${BIN_DIR}/${TARGET_NAME}.framework/Modules/${TARGET_NAME}.swiftmodule/
    fi
done

mkdir -p ${BIN_DIR}/CgRPC.framework/Modules
cat >${BIN_DIR}/CgRPC.framework/Modules/module.modulemap <<EOL
framework module CgRPC {
    header "cgrpc.h"
    export *
}
EOL

mkdir -p ${BIN_DIR}/CgRPC.framework/Headers
cp ${BUILD_DIR}/grpc-swift/Sources/CgRPC/include/cgrpc.h ${BIN_DIR}/CgRPC.framework/Headers/cgrpc.h
