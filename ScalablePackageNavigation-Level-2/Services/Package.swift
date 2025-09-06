// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Services",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "Services",
            targets: ["Services"]
        ),
    ],
    targets: [
        .target(
            name: "Services",
            dependencies: []
        ),
        .testTarget(
            name: "ServicesTests",
            dependencies: ["Services"]
        ),
    ]
)
