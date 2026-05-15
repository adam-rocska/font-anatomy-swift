import FontAnatomyTestSupport
import Foundation
import Testing
@testable import FontAnatomy

@Suite("Font corpus loading", .timeLimit(.minutes(1)))
struct FontCorpusLoadingTests {
  @Test(
    "Loads expected metrics from corpus fixture URLs",
    arguments: FontAnatomyCorpusFixture.allCases
  )
  func loadsExpectedMetricsFromURL(fixture: FontAnatomyCorpusFixture) throws {
    #expect(try FontAnatomy<Int>(FontAnatomyFixture.url(for: fixture)) == fixture.expected)
  }

  @Test(
    "Loads expected metrics from corpus fixture Data",
    arguments: FontAnatomyCorpusFixture.allCases
  )
  func loadsExpectedMetricsFromData(fixture: FontAnatomyCorpusFixture) throws {
    let data = try Data(contentsOf: FontAnatomyFixture.url(for: fixture))

    #expect(try FontAnatomy<Int>(data) == fixture.expected)
  }

  @Test(
    "Loads expected metrics from corpus fixture byte arrays",
    arguments: FontAnatomyCorpusFixture.allCases
  )
  func loadsExpectedMetricsFromBytes(fixture: FontAnatomyCorpusFixture) throws {
    let data = try Data(contentsOf: FontAnatomyFixture.url(for: fixture))

    #expect(try FontAnatomy<Int>(Array(data)) == fixture.expected)
  }

  @Test(
    "Corpus fixture anatomy round-trips through Codable",
    arguments: FontAnatomyCorpusFixture.allCases
  )
  func corpusAnatomyRoundTripsThroughCodable(fixture: FontAnatomyCorpusFixture) throws {
    let encoded = try JSONEncoder().encode(fixture.expected)
    let decoded = try JSONDecoder().decode(FontAnatomy<Int>.self, from: encoded)

    #expect(decoded == fixture.expected)
  }

  @Test(
    "Corpus fixtures have sane vertical anatomy relationships",
    arguments: FontAnatomyCorpusFixture.allCases
  )
  func corpusAnatomyRelationships(fixture: FontAnatomyCorpusFixture) {
    let anatomy = fixture.expected

    #expect(anatomy.unitsPerEm > 0)
    #expect(anatomy.ascender > 0)
    #expect(anatomy.descender < 0)
    #expect(anatomy.xHeight > 0)
    #expect(anatomy.capHeight > 0)
    #expect(anatomy.ascender > anatomy.xHeight)
    #expect(anatomy.ascender > anatomy.capHeight)
    #expect(anatomy.capHeight >= anatomy.xHeight)
  }
}
