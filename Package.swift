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
    .library(name: "FontAnatomy", targets: ["FontAnatomy"]),
    .executable(name: "font-anatomy", targets: ["font-anatomy"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-argument-parser",
      from: "1.7.0"
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
    .systemLibrary(
      name: "CWOFF2Dec",
      pkgConfig: "libwoff2dec",
      providers: [
        .brew(["woff2"]),
        .apt(["libwoff-dev"]),
        .yum(["woff2-devel"]),
      ]
    ),
    .target(
      name: "CWOFF2",
      dependencies: [
        .byName(name: "CWOFF2Dec")
      ],
      publicHeadersPath: "include"
    ),
    .target(
      name: "FontAnatomy",
      dependencies: [
        .byName(
          name: "CFreeType", condition: .when(platforms: cFontBackendPlatforms)),
        .byName(
          name: "CWOFF2", condition: .when(platforms: cFontBackendPlatforms)),
      ]
    ),
    .executableTarget(
      name: "font-anatomy",
      dependencies: [
        .byName(name: "CFreeType"),
        .byName(name: "FontAnatomy"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
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

let cFontBackendPlatforms: [Platform] = [
  .linux,
  .android,
  .wasi,
  .windows,
  .openbsd,
]
