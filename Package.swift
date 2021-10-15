// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SBPAsyncImage",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "SBPAsyncImage",
            targets: ["SBPAsyncImage"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SBPAsyncImage",
            dependencies: []),
        .testTarget(
            name: "SBPAsyncImageTests",
            dependencies: ["SBPAsyncImage"]),
    ]
)
