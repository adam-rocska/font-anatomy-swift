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

  @Test("Loads WOFF2 when the linked FreeType build has Brotli support")
  func loadsWOFF2WhenSupportedByFreeType() throws {
    let url = try FontAnatomyFixture.atkinsonHyperlegibleWOFF2URL()

    do {
      let anatomy = try FontAnatomy<Int>(url)
      #expect(anatomy == FontAnatomy(
        unitsPerEm: 1000,
        ascender: 796,
        descender: -161,
        xHeight: 496,
        capHeight: 668
      ))
    } catch FontAnatomyError.ftLoadFailure(let code) {
      #expect(code != 0)
    } catch {
      Issue.record("Unexpected WOFF2 error: \(error)")
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
