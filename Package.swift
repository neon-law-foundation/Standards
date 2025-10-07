// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Standards",
    dependencies: [
        .package(
            url: "https://github.com/hummingbird-project/postgres-migrations.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "StandardsDAL",
            dependencies: [
                .product(name: "PostgresMigrations", package: "postgres-migrations")
            ]
        )
    ]
)
