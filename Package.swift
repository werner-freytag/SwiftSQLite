// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSQLite",
    platforms: [
        .macOS(.v10_10), .iOS(.v8),
    ],
    products: [
        .library(
            name: "SwiftSQLite",
            targets: ["SwiftSQLite"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftSQLite",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SwiftSQLiteTests",
            dependencies: ["SwiftSQLite"],
            path: "Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
