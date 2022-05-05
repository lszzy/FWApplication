#! /bin/bash

framework_name=FWApplication

mv docs/CNAME ./
rm -rf docs
mkdir docs
mv CNAME docs/
mkdir "docs/$framework_name"

umbrella_name="$framework_name-umbrella.h"
umbrella_path=Example/Pods/Target\ Support\ Files
lib_path="docs/$framework_name/"
vendor_path="Example/build/Release-iphoneos/FWFramework/"
sdk_path=$(xcrun --show-sdk-path --sdk iphonesimulator)
cp "$umbrella_path/$framework_name/$umbrella_name" $lib_path
find "$framework_name/Classes" -type f ! -regex '*.h' -name '*.h' \
    -exec cp {} $lib_path \;

sourcekitten doc -- -project _Pods.xcodeproj -target $framework_name > "$lib_path/swift.json"
sourcekitten doc --objc "$lib_path/$umbrella_name" -- -x objective-c -isysroot $sdk_path -I $lib_path -F $vendor_path -fobjc-arc -fmodules > "$lib_path/objc.json"
jazzy --sourcekitten-sourcefile "$lib_path/swift.json","$lib_path/objc.json"

rm -rf $lib_path
rm -rf Example/build/
cp *.md docs/
