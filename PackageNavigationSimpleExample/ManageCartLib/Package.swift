// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ManageCartLib",
    platforms: [.iOS(.v16)], // Optional: Add platform requirements
    products: [
        .library(
            name: "ManageCartLib",
            targets: ["ManageCartLib"]
        ),
    ],
    dependencies: [
        .package(name: "NavigationLib", path: "../NavigationLib") // Local path
    ],
    targets: [
        .target(
            name: "ManageCartLib",
            dependencies: ["NavigationLib"] // Explicit dependency
        ),
    ]
)
