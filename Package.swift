// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VetBuddy",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "VetBuddy",
            targets: ["VetBuddy"]
        ),
        .executable(
            name: "VetBuddyApp",
            targets: ["VetBuddyApp"]
        )
    ],
    targets: [
        .target(
            name: "VetBuddy",
            path: ".",
            exclude: [
                "App",
                "Tests",
                "Resources",
                "开发文档",
                "UI 参考",
                "VetBuddy.xcodeproj",
                "README.md",
                ".DS_Store"
            ],
            sources: [
                "Core",
                "DesignSystem",
                "Features"
            ],
            resources: [
                .process("Resources/Content")
            ]
        ),
        .executableTarget(
            name: "VetBuddyApp",
            dependencies: ["VetBuddy"],
            path: "App"
        ),
        .testTarget(
            name: "VetBuddyTests",
            dependencies: ["VetBuddy"],
            path: "Tests/VetBuddyTests"
        )
    ]
)
