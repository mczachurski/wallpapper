// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "wallpapper",
    products: [
        .executable(name: "wallpapper", targets: ["wallpapper"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "wallpapper", dependencies: [])
    ]
)
