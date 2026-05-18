import FontAnatomyTestSupport
import Foundation
import Testing

@Suite("Platform contract")
struct PlatformContractTests {
  @Test("Cross-platform sources do not import Apple font or UI frameworks")
  func crossPlatformSourcesAvoidDarwinFontFrameworks() throws {
    for source in try swiftSourceFiles() {
      guard !appleFontIntegrationFiles.contains(source.lastPathComponent) else {
        continue
      }

      for module in try activeImportedModules(in: source) {
        #expect(!appleFontFrameworks.contains(module))
      }
    }
  }

  @Test("Apple font integrations stay compile gated")
  func appleFontIntegrationsStayCompileGated() throws {
    for source in try swiftSourceFiles() {
      guard appleFontIntegrationFiles.contains(source.lastPathComponent) else {
        continue
      }

      let contents = try activeSourceContents(of: source)
      let importedAppleFrameworks = try activeImportedModules(in: source)
        .filter(appleFontFrameworks.contains)

      for framework in importedAppleFrameworks {
        #expect(
          contents.contains("#if canImport(\(framework))"),
          "\(source.lastPathComponent) imports \(framework) without a matching canImport gate"
        )
      }
    }
  }

  @Test("CFreeType shim stays limited to FreeType headers")
  func cFreeTypeShimStaysNarrow() throws {
    let header = PackagePaths.root
      .appendingPathComponent("Sources")
      .appendingPathComponent("CFreeType")
      .appendingPathComponent("CFreeType.h")
    let contents = try String(contentsOf: header, encoding: .utf8)

    #expect(contents.contains("#include <ft2build.h>"))
    #expect(contents.contains("FT_FREETYPE_H"))
    #expect(contents.contains("FT_TRUETYPE_TABLES_H"))
    #expect(!contents.contains("CoreText"))
    #expect(!contents.contains("ApplicationServices"))
  }

  @Test("CWOFF2 shim stays limited to WOFF2 headers")
  func cWOFF2ShimStaysNarrow() throws {
    let header = PackagePaths.root
      .appendingPathComponent("Sources")
      .appendingPathComponent("CWOFF2")
      .appendingPathComponent("include")
      .appendingPathComponent("CWOFF2.h")
    let contents = try String(contentsOf: header, encoding: .utf8)

    #expect(contents.contains("CWOFF2Decompress"))
    #expect(contents.contains("CWOFF2DataFree"))
    #expect(!contents.contains("CoreText"))
    #expect(!contents.contains("ApplicationServices"))
  }
}

private let appleFontIntegrationFiles: Set<String> = [
  "FontAnatomy~CoreText.swift",
  "FontAnatomy~SwiftUIFont.swift",
]

private let appleFontFrameworks: Set<String> = [
  "AppKit",
  "CoreGraphics",
  "CoreText",
  "SwiftUI",
  "UIKit",
  "WatchKit",
]

private func swiftSourceFiles() throws -> [URL] {
  let sources = PackagePaths.root.appendingPathComponent("Sources")
  let enumerator = FileManager.default.enumerator(
    at: sources,
    includingPropertiesForKeys: [.isRegularFileKey]
  )

  var files: [URL] = []
  while let url = enumerator?.nextObject() as? URL {
    guard url.pathExtension == "swift" else { continue }
    files.append(url)
  }
  return files
}

private func activeImportedModules(in source: URL) throws -> Set<String> {
  let contents = try activeSourceContents(of: source)
  return Set(contents.split(separator: "\n").compactMap(importedModule))
}

private func activeSourceContents(of source: URL) throws -> String {
  try String(contentsOf: source, encoding: .utf8)
    .split(separator: "\n", omittingEmptySubsequences: false)
    .map(String.init)
    .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
    .joined(separator: "\n")
}

private func importedModule(from line: String.SubSequence) -> String? {
  var components = line
    .trimmingCharacters(in: .whitespaces)
    .split(separator: " ", omittingEmptySubsequences: true)

  guard components.first == "import" else { return nil }
  components.removeFirst()

  guard let first = components.first else { return nil }
  let importKinds: Set<Substring> = [
    "class",
    "enum",
    "func",
    "let",
    "protocol",
    "struct",
    "typealias",
    "var",
  ]

  let module = importKinds.contains(first)
    ? components.dropFirst().first
    : first

  return module?.split(separator: ".").first.map(String.init)
}
