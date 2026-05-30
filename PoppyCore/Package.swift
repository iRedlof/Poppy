// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PoppyCore",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "PoppyCore", targets: ["PoppyCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.17.0"),
    ],
    targets: [
        .target(
            name: "PoppyCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/PoppyCore",
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
            ]
        ),
        .testTarget(
            name: "PoppyCoreTests",
            dependencies: ["PoppyCore"],
            path: "Tests/PoppyCoreTests",
            resources: [
                .copy("Fixtures")
            ]
        ),
    ]
)
