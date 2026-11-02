// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ErmayMobil",
    defaultLocalization: "tr",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "ErmayMobil",
            targets: ["ErmayMobil"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.5.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.4.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.0")
    ],
    targets: [
        .target(
            name: "ErmayMobil",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Sources/ErmayMobil",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ErmayMobilTests",
            dependencies: ["ErmayMobil"],
            path: "Tests/ErmayMobilTests"
        ),
    ]
)
