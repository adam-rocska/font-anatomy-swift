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
        .byName(name: "CFreeType")
      ]
    ),
    .target(
      name: "FontAnatomyTestSupport",
      dependencies: ["FontAnatomy"],
      path: "Tests/Support",
      resources: [
        .copy("Fixtures")
      ]
    ),
    .testTarget(
      name: "FontAnatomyTests",
      dependencies: [
        "FontAnatomy",
        "FontAnatomyTestSupport",
      ],
      path: "Tests/Unit/FontAnatomyTests"
    ),
    .testTarget(
      name: "FontAnatomyRegressionTests",
      dependencies: [
        "FontAnatomy",
        "FontAnatomyTestSupport",
      ],
      path: "Tests/Regression/FontAnatomyRegressionTests"
    ),
    .testTarget(
      name: "FontAnatomyUserAcceptanceTests",
      dependencies: [
        "FontAnatomy",
        "FontAnatomyTestSupport",
      ],
      path: "Tests/UserAcceptance/FontAnatomyUserAcceptanceTests"
    ),
  ]
)
