// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "RefreshKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "RefreshKit",
            targets: ["RefreshKit"]
        ),
    ],
    targets: [
        .target(
            name: "RefreshKit",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "RefreshKitTests",
            dependencies: ["RefreshKit"],
            path: "Tests"
        ),
    ]
)
