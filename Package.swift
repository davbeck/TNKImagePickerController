// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "TNKImagePickerController",
    platforms: [
        .iOS(.v8),
    ],
    products: [
        .library(
            name: "TNKImagePickerController",
            targets: ["TNKImagePickerController"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TNKImagePickerController",
            path: "TNKImagePickerController",
            publicHeadersPath: "."
        ),
    ]
)
