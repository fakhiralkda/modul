#!/usr/bin/env bash

set -euo pipefail

git clone --recurse-submodules https://github.com/kdrag0n/safetynet-fix
cd safetynet-fix

build_mode="release"
debug_mode=0
  
pushd zygisk/module
rm -fr libs
${ANDROID_HOME}/ndk/21.4.7075529/ndk-build -j48 NDK_DEBUG=${debug_mode}
popd

pushd java
./gradlew assembleRelease
popd

mkdir -p magisk/zygisk
for arch in arm64-v8a armeabi-v7a x86 x86_64
do
    cp "zygisk/module/libs/${arch}/libsafetynetfix.so" "magisk/zygisk/${arch}.so"
done

pushd magisk
version="$(grep '^version=' module.prop  | cut -d= -f2)"
rm -f "../safetynet-fix-${version}.zip" classes.dex
unzip "../java/app/build/outputs/apk/release/app-release.apk" "classes.dex"
zip -r9 "../safetynet-fix-${version}.zip" .
cd ..
curl --upload-file ./safetynet-fix-${version}.zip https://transfer.sh/safetynet-fix-${version}.zip
popd
