// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "RefreshKit",
    products: [
        .library(name: "RefreshKit", targets: ["RefreshKit"]),
    ],
    targets: [
        .target(
            name: "RefreshKit",
            path: "Sources"
        )
    ]
)
