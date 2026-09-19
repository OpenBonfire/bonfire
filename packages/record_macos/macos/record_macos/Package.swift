// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Vendored copy of record_macos 2.1.1 (upstream: https://pub.dev/packages/record_macos),
// patched to fix a real bug in the upstream package: RecorderStreamDelegate.swift
// calls `AVAudioEngine.inputNode.auAudioUnit`, a macOS 13.0+ API, but this
// manifest declared a macOS 10.15 minimum with no `@available` guard around
// that call - so any consumer building against an SDK where the deployment
// target isn't already >=13.0 for unrelated reasons fails to compile. No
// newer record_macos release fixes this as of 2.1.1 (the latest at time of
// writing). Bumping the declared platform to 13.0 here is the minimal fix;
// remove this override package once upstream ships a real fix.

import PackageDescription

let package = Package(
    name: "record_macos",
    platforms: [
        .macOS("13.0")
    ],
    products: [
        // If the plugin name contains "_", replace with "-" for the library name.
        .library(name: "record-macos", targets: ["record_macos"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "record_macos",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/record_macos",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
