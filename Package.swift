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
                .headerSearchPath("FWApplication/Controller"),
                .headerSearchPath("FWApplication/Model"),
                .headerSearchPath("FWApplication/Service"),
                .headerSearchPath("FWApplication/View"),
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
