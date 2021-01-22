// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSQLite",
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
            dependencies: []
        ),
        .testTarget(
            name: "SwiftSQLiteTests",
            dependencies: ["SwiftSQLite"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
