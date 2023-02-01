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
            targets: ["SnabblePayCore", "SnabblePayModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.9.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2")
    ],
    targets: [
        .target(
            name: "SnabblePayNetwork",
            dependencies: [
                "SnabblePayModels",
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
                "SnabblePayModels",
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
            path: "Tests/Core"
        ),
        .target(
            name: "SnabblePayModels",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
            ],
            path: "Sources/Models"
        )
    ]
)
