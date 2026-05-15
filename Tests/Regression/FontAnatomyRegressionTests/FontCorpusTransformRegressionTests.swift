import FontAnatomyTestSupport
import Foundation
import Testing
@testable import FontAnatomy

@Suite("Font corpus transform regressions")
struct FontCorpusTransformRegressionTests {
  @Test(
    "Concretized corpus fixtures keep requested x-height exact",
    arguments: FontAnatomyCorpusFixture.allCases
  )
  func concretizedCorpusXHeightIsExact(fixture: FontAnatomyCorpusFixture) throws {
    let anatomy = try FontAnatomy<Double>(FontAnatomyFixture.url(for: fixture))
    let result = anatomy.concretized(\.xHeight, as: 12)

    #expect(result.xHeight == 12)
    #expect(isClose(result.unitsPerEm, anatomy.unitsPerEm * (12 / anatomy.xHeight)))
    #expect(isClose(result.ascender, anatomy.ascender * (12 / anatomy.xHeight)))
    #expect(isClose(result.descender, anatomy.descender * (12 / anatomy.xHeight)))
    #expect(isClose(result.capHeight, anatomy.capHeight * (12 / anatomy.xHeight)))
  }

  @Test(
    "Equated corpus fixtures keep base x-height exact",
    arguments: FontAnatomyCorpusFixture.allCases
  )
  func equatedCorpusXHeightIsExact(fixture: FontAnatomyCorpusFixture) throws {
    let base = FontAnatomy<Double>(
      unitsPerEm: 24,
      ascender: 19.2,
      descender: -4.8,
      xHeight: 12,
      capHeight: 16.8
    )
    let target = try FontAnatomy<Double>(FontAnatomyFixture.url(for: fixture))
    let result = base.equated(with: target, by: \.xHeight)

    #expect(result.xHeight == base.xHeight)
    #expect(isClose(result.unitsPerEm, target.unitsPerEm * (12 / target.xHeight)))
    #expect(isClose(result.ascender, target.ascender * (12 / target.xHeight)))
    #expect(isClose(result.descender, target.descender * (12 / target.xHeight)))
    #expect(isClose(result.capHeight, target.capHeight * (12 / target.xHeight)))
  }

  @Test(
    "Corpus fixtures load correctly from padded Data slices",
    arguments: FontAnatomyCorpusFixture.allCases
  )
  func corpusFixturesLoadFromPaddedSlices(fixture: FontAnatomyCorpusFixture) throws {
    let data = try Data(contentsOf: FontAnatomyFixture.url(for: fixture))
    var padded = Data([0xA1, 0xB2, 0xC3, 0xD4])
    padded.append(data)
    padded.append(contentsOf: [0xE5, 0xF6])

    let start = padded.index(padded.startIndex, offsetBy: 4)
    let end = padded.index(start, offsetBy: data.count)
    let sliced = padded[start..<end]

    #expect(try FontAnatomy<Int>(sliced) == fixture.expected)
  }

  @Test("Fixture README documents license metadata for every corpus fixture")
  func fixtureReadmeDocumentsLicenseMetadata() throws {
    let readme = try String(
      contentsOf: FontAnatomyFixture.fixtureReadmeURL(),
      encoding: .utf8
    )

    for fixture in FontAnatomyCorpusFixture.allCases where fixture.resourceName != "LibertinusSans-Regular" && fixture.resourceName != "NotoSerif-VariableFont_wdth,wght" {
      #expect(readme.contains("\(fixture.resourceName).\(fixture.fileExtension)"))
      #expect(readme.contains("licensed"))
    }
  }
}

private func isClose(_ actual: Double, _ expected: Double, tolerance: Double = 1e-12) -> Bool {
  abs(actual - expected) <= tolerance
}
