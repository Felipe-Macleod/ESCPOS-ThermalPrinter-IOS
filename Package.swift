// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ESCPOS-ThermalPrinter-IOS",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ESCPOS-ThermalPrinter-IOS",
            targets: ["ESCPOS-ThermalPrinter-IOS"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ESCPOS-ThermalPrinter-IOS"),
        .testTarget(
            name: "ESCPOS-ThermalPrinter-IOSTests",
            dependencies: ["ESCPOS-ThermalPrinter-IOS"]),
    ]
)
