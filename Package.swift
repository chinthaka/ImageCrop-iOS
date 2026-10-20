// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ImageCrop",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "ImageCrop", targets: ["ImageCrop"]),
    ],
    targets: [
        .target(name: "ImageCrop"),
        .testTarget(
            name: "ImageCropTests",
            dependencies: ["ImageCrop"]
        ),
    ]
)
