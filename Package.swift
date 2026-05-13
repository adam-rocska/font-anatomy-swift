// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "FontAnatomy",
  products: [
    .library(
      name: "FontAnatomy",
      targets: ["FontAnatomy"]
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
      dependencies: ["CFreeType"]
    ),
    .testTarget(
      name: "FontAnatomyTests",
      dependencies: ["FontAnatomy"],
      resources: [
        .copy("Fixtures"),
      ]
    ),
  ]
)
