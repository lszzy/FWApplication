#! /bin/bash

framework_name=FWApplication

mv Document/CNAME ./
rm -rf Document
mkdir Document
mv CNAME Document/
mkdir "Document/$framework_name"

umbrella_name="$framework_name-umbrella.h"
umbrella_path=Example/Pods/Target\ Support\ Files
cp "$umbrella_path/$framework_name/$umbrella_name" "Document/$framework_name/"
find "$framework_name/Classes" -type f ! -regex '*.h' -name '*.h' \
    -exec cp {} "Document/$framework_name/" \;

sourcekitten doc -- -project _Pods.xcodeproj -target $framework_name > "Document/$framework_name/swift.json"
sourcekitten doc --objc "Document/$framework_name/$umbrella_name" -- -x objective-c -isysroot $(xcrun --show-sdk-path --sdk iphonesimulator) -I $(pwd) -fmodules > "Document/$framework_name/objc.json"
jazzy --output Document --sourcekitten-sourcefile "Document/$framework_name/swift.json","Document/$framework_name/objc.json"

rm -rf "Document/$framework_name"
cp *.md Document/
