// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SQLite",
    platforms: [
        .macOS(.v10_10), .iOS(.v8),
    ],
    products: [
        .library(
            name: "SQLite",
            targets: ["SQLite"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SQLite",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SQLiteTests",
            dependencies: ["SQLite"],
            path: "Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
