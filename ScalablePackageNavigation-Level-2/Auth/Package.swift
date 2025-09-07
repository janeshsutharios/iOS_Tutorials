// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Auth",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "Auth",
            targets: ["Auth"]
        ),
    ],
    dependencies: [
        .package(path: "../CoreNavigation"),
        .package(path: "../Services"),
    ],
    targets: [
        .target(
            name: "Auth",
            dependencies: ["CoreNavigation", "Services"]
        ),
        .testTarget(
            name: "AuthTests",
            dependencies: ["Auth"]
        ),
    ]
)
