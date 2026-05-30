// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Poppy",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(path: "PoppyCore"),
    ],
    targets: [
        .executableTarget(
            name: "Poppy",
            dependencies: [
                .product(name: "PoppyCore", package: "PoppyCore"),
            ],
            path: "Poppy",
            exclude: ["Info.plist", "Poppy.entitlements", "Assets.xcassets", "Localizable.xcstrings"]
        ),
    ]
)
