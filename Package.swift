// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Gandi-Swift",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "Gandi-Swift",
            targets: ["Gandi-Swift"]
        )
    ],
    dependencies: [
        // 添加必要的依赖
    ],
    targets: [
        .executableTarget(
            name: "Gandi-Swift",
            dependencies: [],
            path: "Sources",
            resources: [
                .copy("Pages/index.html")
            ]
        )
    ]
)
