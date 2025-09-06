// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
let package = Package(
    name: "Profile",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "Profile",
            targets: ["Profile"]
        ),
    ],
    dependencies: [
        .package(path: "../CoreNavigation"),
        .package(path: "../Services"),
    ],
    targets: [
        .target(
            name: "Profile",
            dependencies: ["CoreNavigation", "Services"]
        )
    ]
)
