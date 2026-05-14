// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "FontAnatomy",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .tvOS(.v17),
    .watchOS(.v10),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "FontAnatomy", targets: ["FontAnatomy"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/adam-rocska/VersionInfo.swift",
      from: "1.0.0"
    )
  ],
  targets: [
    .systemLibrary(
      name: "CFreeType",
      pkgConfig: "freetype2",
      providers: [
        .brew(["freetype"]),
        .apt(["libfreetype6-dev"]),
        .yum(["freetype-devel"]),
      ]
    ),
    .target(
      name: "FontAnatomy",
      dependencies: [
        .byName(name: "CFreeType"),
        .product(name: "VersionInfo", package: "VersionInfo.swift"),
      ]
    ),
    .testTarget(
      name: "FontAnatomyTests",
      dependencies: ["FontAnatomy"],
      resources: [
        .copy("Fixtures")
      ]
    ),
  ]
)
