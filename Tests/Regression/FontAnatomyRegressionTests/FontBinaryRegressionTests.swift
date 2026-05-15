import FontAnatomyTestSupport
import Foundation
import Testing
@testable import FontAnatomy

@Suite("Font binary regressions")
struct FontBinaryRegressionTests {
  @Test("Parses font data from a Data slice with leading and trailing padding")
  func parsesSlicedData() throws {
    let font = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())
    var padded = Data([1, 2, 3, 4, 5])
    padded.append(font)
    padded.append(contentsOf: [6, 7, 8])

    let start = padded.index(padded.startIndex, offsetBy: 5)
    let end = padded.index(start, offsetBy: font.count)
    let sliced = padded[start..<end]

    #expect(try FontAnatomy<Int>(sliced) == FontAnatomy(
      unitsPerEm: 1000,
      ascender: 894,
      descender: -246,
      xHeight: 460,
      capHeight: 658
    ))
  }

  @Test("Rejects a readable non-font file through the URL initializer")
  func rejectsReadableNonFontFile() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let url = try temporaryDirectory.write("not a font", to: "not-a-font.txt")

    do {
      _ = try FontAnatomy<Int>(url)
      Issue.record("Expected FreeType to reject a readable non-font file")
    } catch FontAnatomyError.ftLoadFailure {
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Extracted metrics come from the OS/2 x-height and cap-height fields")
  func extractsOS2HeightFields() throws {
    let anatomy = try FontAnatomy<Int>(FontAnatomyFixture.libertinusSansRegularURL())

    #expect(anatomy.unitsPerEm == 1000)
    #expect(anatomy.ascender == 894)
    #expect(anatomy.descender == -246)
    #expect(anatomy.xHeight == 460)
    #expect(anatomy.capHeight == 658)
    #expect(anatomy.xHeight != anatomy.ascender)
    #expect(anatomy.capHeight != anatomy.ascender)
    #expect(anatomy.xHeight != anatomy.capHeight)
  }
}
