// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Dashboard",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "Dashboard",
            targets: ["Dashboard"]
        ),
    ],
    dependencies: [
        .package(path: "../CoreNavigation"),
        .package(path: "../Services"),
    ],
    targets: [
        .target(
            name: "Dashboard",
            dependencies: ["CoreNavigation", "Services"]
        ),
        .testTarget(
            name: "DashboardTests",
            dependencies: ["Dashboard"]
        ),
    ]
)
