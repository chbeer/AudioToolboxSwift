// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AudioToolboxSwift",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AudioToolboxSwift",
            targets: ["AudioToolboxSwift"]),
        .library(
            name: "AudioToolboxSwift-Ogg",
            targets: ["AudioToolboxSwift-Ogg"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AudioToolboxSwift",
            dependencies: []),
        .target(
            name: "AudioToolboxSwift-Ogg",
            dependencies: ["AudioToolboxSwift", "ogg", "vorbis"],
            linkerSettings: [
                .linkedFramework("ogg"),
                .linkedFramework("vorbis"),
            ]
        ),
        .testTarget(
            name: "AudioToolboxSwiftTests",
            dependencies: ["AudioToolboxSwift"]),
        
        .binaryTarget(
            name: "ogg",
            path: "Sources/Ogg/ogg.xcframework"),
        .binaryTarget(
            name: "vorbis",
            path: "Sources/Vorbis/vorbis.xcframework"),
    ]
)
