// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RecipeKitShared",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "RecipeKitShared",
            targets: ["RecipeKitShared"]
        ),
    ],
    targets: [
        .target(
            name: "RecipeKitShared",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "RecipeKitSharedTests",
            dependencies: ["RecipeKitShared"]
        ),
    ]
)
