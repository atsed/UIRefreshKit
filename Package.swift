// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "UIRefreshKit",
    products: [
        .library(name: "UIRefreshKit", targets: ["UIRefreshKit"]),
    ],
    targets: [
        .target(
            name: "UIRefreshKit",
            path: "Sources"
        )
    ]
)
