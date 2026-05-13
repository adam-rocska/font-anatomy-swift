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
    .target(
      name: "FontAnatomy"
    ),
    .testTarget(
      name: "FontAnatomyTests",
      dependencies: ["FontAnatomy"]
    ),
  ]
)
