// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "KarenKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "KarenKit",
            targets: ["KarenKit"]
        ),
        .library(
            name: "KarenShared",
            targets: ["KarenShared"]
        ),
        .library(
            name: "KarenClient",
            targets: ["KarenClient"]
        ),
        .library(
            name: "KarenAtlas",
            targets: ["KarenAtlas"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/vapor/fluent.git",
            from: "4.9.0"
        ),
        .package(
            url: "https://github.com/vapor/fluent-sqlite-driver.git",
            from: "4.0.0"
        ),
        .package(
            url: "https://github.com/vapor/vapor.git",
            from: "4.117.0"
        )
    ],
    targets: [
        .target(
            name: "KarenKit"
        ),
        .target(
            name: "KarenShared",
            dependencies: [
                "KarenKit"
            ]
        ),
        .target(
            name: "KarenClient",
            dependencies: [
                "KarenKit"
            ]
        ),
        .target(
            name: "KarenAtlas",
            dependencies: [
                .product(
                    name: "Fluent",
                    package: "fluent"
                )
            ]
        ),
        .testTarget(
            name: "KarenAtlasTests",
            dependencies: [
                "KarenAtlas",
                .product(
                    name: "Fluent",
                    package: "fluent"
                ),
                .product(
                    name: "FluentSQLiteDriver",
                    package: "fluent-sqlite-driver"
                ),
                .product(
                    name: "Vapor",
                    package: "vapor"
                )
            ]
        )
    ]
)
