// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SnabblePay",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SnabblePay",
            targets: ["SnabblePayCore", "SnabblePayUI"]),
        .library(
            name: "SnabblePayCore",
            targets: ["SnabblePayCore"]
        ),
        .library(
            name: "SnabblePayUI",
            targets: ["SnabblePayUI"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SnabblePayCore",
            path: "Sources/Core",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SnabblePayCoreTests",
            dependencies: ["SnabblePayCore"],
            path: "Tests/Core",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "SnabblePayUI",
            dependencies: ["SnabblePayCore"],
            path: "Sources/UI",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SnabblePayUITests",
            dependencies: ["SnabblePayCore", "SnabblePayUI"],
            path: "Tests/UI"
        ),
    ]
)
