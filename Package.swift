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
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/realm/SwiftLint", exact: "0.51.0"),
    ],
    targets: [
        .target(
            name: "SnabbleLogger",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/Logger"
        ),
        .target(
            name: "SnabblePayNetwork",
            dependencies: [
                "SnabbleLogger",
            ],
            path: "Sources/Network"
        ),
        .target(
            name: "SnabblePay",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
                "SnabblePayNetwork",
                "SnabbleLogger",
            ],
            path: "Sources/Core",
            plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
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
