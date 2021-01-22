// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "wallpapper",
    products: [
        .library(name: "WallpapperLib", targets: ["WallpapperLib"]),
        .executable(name: "wallpapper", targets: ["Wallpapper"]),
        .executable(name: "wallpapper-exif", targets: ["WallpapperExif"])
    ],
    dependencies: [],
    targets: [
        .target(name: "WallpapperLib", dependencies: []),
        .target(name: "Wallpapper", dependencies: ["WallpapperLib"]),
        .target(name: "WallpapperExif", dependencies: ["WallpapperLib"])
    ]
)
