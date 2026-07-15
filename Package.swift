// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Divide",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Divide",
            path: "Sources/Divide"
        ),
        .testTarget(
            name: "DivideTests",
            dependencies: ["Divide"],
            path: "Tests/DivideTests"
        )
    ]
)
