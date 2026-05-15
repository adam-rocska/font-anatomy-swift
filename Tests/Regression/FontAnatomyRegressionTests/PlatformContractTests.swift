import FontAnatomyTestSupport
import Foundation
import Testing

@Suite("Platform contract")
struct PlatformContractTests {
  @Test("FontAnatomy sources do not import Apple font or UI frameworks")
  func sourcesAvoidDarwinFontFrameworks() throws {
    let forbiddenImports = [
      "import AppKit",
      "import CoreGraphics",
      "import CoreText",
      "import SwiftUI",
      "import UIKit",
    ]

    for source in try swiftSourceFiles() {
      let contents = try String(contentsOf: source, encoding: .utf8)
      for forbiddenImport in forbiddenImports {
        #expect(!contents.contains(forbiddenImport))
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
}

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
