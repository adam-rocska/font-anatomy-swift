// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "FontAnatomy",
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
