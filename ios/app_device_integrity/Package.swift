// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "app_device_integrity",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "app-device-integrity", type: .static, targets: ["app_device_integrity"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "app_device_integrity",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)

