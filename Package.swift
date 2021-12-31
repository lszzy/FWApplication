// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FWApplication",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "FWApplication",
            targets: ["FWApplication"]),
        .library(
            name: "FWApplicationCompatible",
            targets: ["FWApplication", "FWApplicationCompatible"]),
        .library(
            name: "FWApplicationSDWebImage",
            targets: ["FWApplication", "FWApplicationSDWebImage"])
    ],
    dependencies: [
        .package(url: "https://github.com/lszzy/FWFramework.git", from: "2.1.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.9.0"),
    ],
    targets: [
        .target(
            name: "FWApplication",
            dependencies: ["FWFramework"],
            path: "FWApplication/Classes",
            sources: [
                "FWApplication/App",
                "FWApplication/Controller",
                "FWApplication/Model",
                "FWApplication/Service",
                "FWApplication/View"
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("FWApplication/App"),
                .headerSearchPath("FWApplication/App/App"),
                .headerSearchPath("FWApplication/App/Plugin/Alert"),
                .headerSearchPath("FWApplication/App/Plugin/Empty"),
                .headerSearchPath("FWApplication/App/Plugin/Image"),
                .headerSearchPath("FWApplication/App/Plugin/Picker"),
                .headerSearchPath("FWApplication/App/Plugin/Preview"),
                .headerSearchPath("FWApplication/App/Plugin/Refresh"),
                .headerSearchPath("FWApplication/App/Plugin/Toast"),
                .headerSearchPath("FWApplication/App/Plugin/View"),
                .headerSearchPath("FWApplication/Controller"),
                .headerSearchPath("FWApplication/Model"),
                .headerSearchPath("FWApplication/Model/Extension"),
                .headerSearchPath("FWApplication/Service"),
                .headerSearchPath("FWApplication/Service/Cache"),
                .headerSearchPath("FWApplication/Service/Database"),
                .headerSearchPath("FWApplication/Service/Media"),
                .headerSearchPath("FWApplication/Service/Network"),
                .headerSearchPath("FWApplication/Service/Request"),
                .headerSearchPath("FWApplication/Service/Socket"),
                .headerSearchPath("FWApplication/View"),
                .headerSearchPath("FWApplication/Component"),
                .headerSearchPath("FWApplication/Extension"),
                .headerSearchPath("include")
            ]),
        .target(
            name: "FWApplicationCompatible",
            dependencies: ["FWApplication"],
            path: "FWApplication/Classes/Module/Compatible",
            cSettings: [
                .define("FWApplicationSPM", to: "1")
            ],
            swiftSettings: [
                .define("DEBUG", .when(platforms: [.iOS], configuration: .debug)),
                .define("FWApplicationSPM")
            ]),
        .target(
            name: "FWApplicationSDWebImage",
            dependencies: ["FWApplication", "SDWebImage"],
            path: "FWApplication/Classes/Module/SDWebImage",
            cSettings: [
                .define("FWApplicationSPM", to: "1")
            ],
            swiftSettings: [
                .define("FWApplicationSPM")
            ]),
    ]
)
