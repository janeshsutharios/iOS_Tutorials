// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Messages",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "Messages",
            targets: ["Messages"]
        ),
    ],
    dependencies: [
        .package(path: "../CoreNavigation"),
        .package(path: "../Services"),
    ],
    targets: [
        .target(
            name: "Messages",
            dependencies: ["CoreNavigation", "Services"]
        ),
        .testTarget(
            name: "MessagesTests",
            dependencies: ["Messages"]
        ),
    ]
)
