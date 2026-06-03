import Foundation

public struct FontAnatomyConsumerPackage: Sendable {
  public let directory: URL
  public let executableName: String

  public static func create(
    in directory: URL,
    name: String,
    main: String
  ) throws -> FontAnatomyConsumerPackage {
    let sourceDirectory = directory
      .appendingPathComponent("Sources", isDirectory: true)
      .appendingPathComponent(name, isDirectory: true)
    try FileManager.default.createDirectory(at: sourceDirectory, withIntermediateDirectories: true)

    try packageManifest(name: name).write(
      to: directory.appendingPathComponent("Package.swift"),
      atomically: true,
      encoding: .utf8
    )

    try main.write(
      to: sourceDirectory.appendingPathComponent("main.swift"),
      atomically: true,
      encoding: .utf8
    )

    return FontAnatomyConsumerPackage(directory: directory, executableName: name)
  }

  private static func packageManifest(name: String) -> String {
    """
    // swift-tools-version: 6.0

    import PackageDescription

    let package = Package(
      name: "\(name)",
      platforms: [.macOS(.v14)],
      dependencies: [
        .package(path: \(String(reflecting: PackagePaths.root.path)))
      ],
      targets: [
        .executableTarget(
          name: "\(name)",
          dependencies: [
            .product(name: "FontAnatomy", package: "font-anatomy-swift")
          ]
        )
      ]
    )
    """
  }
}
