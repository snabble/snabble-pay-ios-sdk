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
            targets: ["SnabblePay"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0")
    ],
    targets: [
        .target(
            name: "SnabblePayNetwork",
            dependencies: [],
            path: "Sources/Network"
        ),

        .target(
            name: "SnabblePay",
            dependencies: [
                "SnabblePayNetwork",
                .product(name: "Tagged", package: "swift-tagged"),
            ],
            path: "Sources/Core"
        ),
        .target(
            name: "TestHelper",
            dependencies: [],
            path: "Tests/Helper"
        ),
        .testTarget(
            name: "SnabblePayCoreTests",
            dependencies: [
                "SnabblePay",
                "TestHelper"
            ],
            path: "Tests/Core",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SnabblePayNetworkTests",
            dependencies: [
                "SnabblePayNetwork",
                "TestHelper",
            ],
            path: "Tests/Network",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
