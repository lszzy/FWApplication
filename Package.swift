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
            targets: ["FWApplication", "FWApplicationSDWebImage"]),
        .library(
            name: "FWApplicationLottie",
            targets: ["FWApplication", "FWApplicationLottie"]),
    ],
    dependencies: [
        .package(url: "https://github.com/lszzy/FWFramework.git", from: "3.6.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.9.0"),
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "3.2.0"),
    ],
    targets: [
        .target(
            name: "FWApplication",
            dependencies: [
                "FWFramework",
                .product(name: "FWFrameworkCompatible", package: "FWFramework")
            ],
            path: "FWApplication/Classes",
            sources: [
                "FWApplication/Module",
                "FWApplication/Plugin",
                "FWApplication/Service",
                "FWApplication/Toolkit"
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("FWApplication/Module/App"),
                .headerSearchPath("FWApplication/Module/Controller"),
                .headerSearchPath("FWApplication/Module/Model"),
                .headerSearchPath("FWApplication/Module/View"),
                .headerSearchPath("FWApplication/Plugin/Alert"),
                .headerSearchPath("FWApplication/Plugin/Empty"),
                .headerSearchPath("FWApplication/Plugin/Image"),
                .headerSearchPath("FWApplication/Plugin/Picker"),
                .headerSearchPath("FWApplication/Plugin/Preview"),
                .headerSearchPath("FWApplication/Plugin/Refresh"),
                .headerSearchPath("FWApplication/Plugin/Toast"),
                .headerSearchPath("FWApplication/Plugin/View"),
                .headerSearchPath("FWApplication/Service/Cache"),
                .headerSearchPath("FWApplication/Service/Database"),
                .headerSearchPath("FWApplication/Service/Media"),
                .headerSearchPath("FWApplication/Service/Network"),
                .headerSearchPath("FWApplication/Service/Request"),
                .headerSearchPath("FWApplication/Service/Socket"),
                .headerSearchPath("FWApplication/Toolkit/Foundation"),
                .headerSearchPath("FWApplication/Toolkit/UIKit"),
                .headerSearchPath("FWApplication/Toolkit/Component"),
                .headerSearchPath("include"),
                .define("FWMacroSPM", to: "1")
            ],
            swiftSettings: [
                .define("DEBUG", .when(platforms: [.iOS], configuration: .debug)),
                .define("FWMacroSPM")
            ]),
        .target(
            name: "FWApplicationCompatible",
            dependencies: ["FWApplication"],
            path: "FWApplication/Classes/Compatible",
            cSettings: [
                .define("FWMacroSPM", to: "1")
            ],
            swiftSettings: [
                .define("DEBUG", .when(platforms: [.iOS], configuration: .debug)),
                .define("FWMacroSPM")
            ]),
        .target(
            name: "FWApplicationSDWebImage",
            dependencies: ["FWApplication", "SDWebImage"],
            path: "FWApplication/Classes/SDWebImage",
            cSettings: [
                .define("FWMacroSPM", to: "1")
            ],
            swiftSettings: [
                .define("FWMacroSPM")
            ]),
        .target(
            name: "FWApplicationLottie",
            dependencies: [
                "FWApplication",
                .product(name: "Lottie", package: "lottie-ios")
            ],
            path: "FWApplication/Classes/Lottie",
            cSettings: [
                .define("FWMacroSPM", to: "1")
            ],
            swiftSettings: [
                .define("FWMacroSPM")
            ]),
    ]
)
