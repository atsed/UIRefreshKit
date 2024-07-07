// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "PullToRefresh&Pagination",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "PullToRefresh&Pagination",
            targets: ["PullToRefresh&Pagination"]
        ),
    ],
    targets: [
        .target(
            name: "PullToRefresh&Pagination",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "PullToRefresh&PaginationTests",
            dependencies: ["PullToRefresh&Pagination"],
            path: "Tests"
        ),
    ]
)
