// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ITSupportMarketplace",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "MarketplaceCore",
            targets: ["MarketplaceCore"]
        )
    ],
    targets: [
        .target(
            name: "MarketplaceCore",
            path: "Sources/MarketplaceCore"
        ),
        .testTarget(
            name: "MarketplaceCoreTests",
            dependencies: ["MarketplaceCore"],
            path: "Tests/MarketplaceCoreTests"
        )
    ]
)
