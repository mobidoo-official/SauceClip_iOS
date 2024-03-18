// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SauceClip_iOS",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SauceClip_iOS",
            targets: ["SauceClip_iOS"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SauceClip_iOS"),
        .testTarget(
            name: "SauceClip_iOSTests",
            dependencies: ["SauceClip_iOS"]),
    ]
)
