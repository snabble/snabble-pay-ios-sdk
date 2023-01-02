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
        ),
        .library(
            name: "SnabblePayNetwork",
            targets: ["SnabblePayNetwork"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.9.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2")
    ],
    targets: [
        .target(
            name: "SnabblePayNetwork",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
                "KeychainAccess"
            ],
            path: "Sources/Network"
        ),
        .testTarget(
            name: "SnabblePayNetworkTests",
            dependencies: [
                "SnabblePayNetwork",
            ],
            path: "Tests/Network",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "SnabblePayCore",
            dependencies: [
                "SnabblePayNetwork",
            ],
            path: "Sources/Core",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SnabblePayCoreTests",
            dependencies: [
                "SnabblePayCore",
            ],
            path: "Tests/Core",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "SnabblePayUI",
            dependencies: [
                "SnabblePayCore"
            ],
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
