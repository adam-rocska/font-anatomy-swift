import FontAnatomyTestSupport
import Foundation
import Testing
@testable import FontAnatomy

@Suite("Font format loading", .timeLimit(.minutes(1)))
struct FontFormatLoadingTests {
  @Test("Loads variable TTF anatomy from the TypeScript parity corpus")
  func loadsVariableTTF() throws {
    let anatomy = try FontAnatomy<Int>(FontAnatomyFixture.notoSerifVariableURL())

    #expect(anatomy == FontAnatomy(
      unitsPerEm: 1000,
      ascender: 1069,
      descender: -293,
      xHeight: 536,
      capHeight: 714
    ))
  }

  @Test("Loads WOFF2 through package-manager-provided WOFF2 decompression")
  func loadsWOFF2ThroughSystemWOFF2Decoder() throws {
    let url = try FontAnatomyFixture.atkinsonHyperlegibleWOFF2URL()
    let data = try Data(contentsOf: url)
    let expected = FontAnatomy(
      unitsPerEm: 1000,
      ascender: 796,
      descender: -161,
      xHeight: 496,
      capHeight: 668
    )

    #expect(try FontAnatomy<Int>(url) == expected)
    #expect(try FontAnatomy<Int>(data) == expected)
    #expect(try FontAnatomy<Int>(Array(data)) == expected)

    let unsafeAnatomy = try data.withUnsafeBytes {
      try FontAnatomy<Int>($0)
    }
    #expect(unsafeAnatomy == expected)
  }

  @Test("Rejects WOFF2-shaped garbage through the WOFF2 decompression path")
  func rejectsInvalidWOFF2ThroughDecompressionPath() {
    let invalidWOFF2 = Array("wOF2not a real font".utf8)

    do {
      _ = try FontAnatomy<Int>(invalidWOFF2)
      Issue.record("Expected invalid WOFF2 bytes to fail")
    } catch FontAnatomyError.woff2DecompressionFailure(let code) {
      #expect(code != 0)
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Loads OTF fixtures when the support bundle contains them")
  func loadsOptionalOTFFixtures() throws {
    for url in FontAnatomyFixture.optionalFixtureURLs(withExtension: "otf") {
      let anatomy = try FontAnatomy<Int>(url)

      #expect(anatomy.unitsPerEm > 0)
      #expect(anatomy.xHeight > 0)
      #expect(anatomy.capHeight > 0)
      #expect(anatomy.ascender > anatomy.descender)
    }
  }
}
