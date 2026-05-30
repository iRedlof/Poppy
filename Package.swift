// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Poppy",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(path: "PoppyCore"),
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.6.0"),
    ],
    targets: [
        .executableTarget(
            name: "Poppy",
            dependencies: [
                .product(name: "PoppyCore", package: "PoppyCore"),
                .product(name: "Sparkle", package: "Sparkle"),
            ],
            path: "Poppy",
            exclude: ["Info.plist", "Poppy.entitlements", "Assets.xcassets", "Localizable.xcstrings"]
        ),
    ]
)
