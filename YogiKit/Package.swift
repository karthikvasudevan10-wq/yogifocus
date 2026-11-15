// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "YogiKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .watchOS(.v11)],
    products: [.library(name: "YogiKit", targets: ["YogiKit"])],
    targets: [
        .target(name: "YogiKit", resources: [.process("Resources")])
    ],
    swiftLanguageModes: [.v5
    ]
)
