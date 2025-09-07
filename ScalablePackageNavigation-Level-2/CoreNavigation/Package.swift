// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "CoreNavigation",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "CoreNavigation",
            targets: ["CoreNavigation"]
        ),
    ],
    targets: [
        .target(
            name: "CoreNavigation",
            dependencies: []
        ),
        .testTarget(
            name: "CoreNavigationTests",
            dependencies: ["CoreNavigation"]
        ),
    ]
)
