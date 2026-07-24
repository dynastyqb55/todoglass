// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TodoGlass",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "TodoGlass",
            path: "Sources/TodoGlass"
        )
    ]
)
