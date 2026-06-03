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
    .target(
      name: "FontAnatomy",
      dependencies: [
        .byName(
          name: "CFreeType",
          condition: .when(platforms: .cFont)
        ),
        .byName(
          name: "CWOFF2",
          condition: .when(platforms: .cFont)
        ),
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

    /// MARK: C Font Libraries
    .target(
      name: "CWOFF2",
      dependencies: ["CWOFF2Dec"],
      path: "Sources/plumbing/CWOFF2",
      publicHeadersPath: "include",
    ),
    .systemLibrary(
      name: "CFreeType",
      path: "Sources/Plumbing/CFreeType",
      pkgConfig: "freetype2",
      providers: [
        .brew(["freetype"]),
        .apt(["libfreetype6-dev"]),
        .yum(["freetype-devel"]),
      ],
    ),
    .systemLibrary(
      name: "CWOFF2Dec",
      path: "Sources/Plumbing/CWOFF2Dec",
      pkgConfig: "libwoff2dec",
      providers: [
        .brew(["woff2"]),
        .apt(["libwoff-dev"]),
        .yum(["woff2-devel"]),
      ]
    ),

    /// MARK: Tests
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
    .target(
      name: "FontAnatomyTestSupport",
      dependencies: ["FontAnatomy"],
      path: "Tests/TestSupport",
      resources: [
        .copy("Fixtures")
      ]
    ),
  ]
)

/// Platforms where the C font libraries are available.
extension Array where Element == Platform {
  static let cFont: Self = [
    .linux,
    .android,
    .wasi,
    .windows,
    .openbsd,
  ]
}
