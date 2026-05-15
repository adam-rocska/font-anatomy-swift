import Foundation
import Testing
@testable import FontAnatomy

@Suite("FontAnatomy value")
struct FontAnatomyValueTests {
  @Test("Memberwise initializer preserves all metric values")
  func memberwiseInitializer() {
    let anatomy = FontAnatomy(
      unitsPerEm: 1000,
      ascender: 894,
      descender: -246,
      xHeight: 460,
      capHeight: 658
    )

    #expect(anatomy.unitsPerEm == 1000)
    #expect(anatomy.ascender == 894)
    #expect(anatomy.descender == -246)
    #expect(anatomy.xHeight == 460)
    #expect(anatomy.capHeight == 658)
  }

  @Test("Codable round-trips the metric payload")
  func codableRoundTrip() throws {
    let anatomy = FontAnatomy(
      unitsPerEm: 1000,
      ascender: 894,
      descender: -246,
      xHeight: 460,
      capHeight: 658
    )

    let encoded = try JSONEncoder().encode(anatomy)
    let decoded = try JSONDecoder().decode(FontAnatomy<Int>.self, from: encoded)
    let object = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: Int])

    #expect(decoded == anatomy)
    #expect(object == [
      "unitsPerEm": 1000,
      "ascender": 894,
      "descender": -246,
      "xHeight": 460,
      "capHeight": 658,
    ])
  }

  @Test("Equatable distinguishes each individual metric")
  func equatableDistinguishesEachMetric() {
    let anatomy = FontAnatomy(
      unitsPerEm: 1000,
      ascender: 894,
      descender: -246,
      xHeight: 460,
      capHeight: 658
    )

    #expect(anatomy == anatomy)
    #expect(anatomy != FontAnatomy(
      unitsPerEm: 999,
      ascender: 894,
      descender: -246,
      xHeight: 460,
      capHeight: 658
    ))
    #expect(anatomy != FontAnatomy(
      unitsPerEm: 1000,
      ascender: 893,
      descender: -246,
      xHeight: 460,
      capHeight: 658
    ))
    #expect(anatomy != FontAnatomy(
      unitsPerEm: 1000,
      ascender: 894,
      descender: -245,
      xHeight: 460,
      capHeight: 658
    ))
    #expect(anatomy != FontAnatomy(
      unitsPerEm: 1000,
      ascender: 894,
      descender: -246,
      xHeight: 459,
      capHeight: 658
    ))
    #expect(anatomy != FontAnatomy(
      unitsPerEm: 1000,
      ascender: 894,
      descender: -246,
      xHeight: 460,
      capHeight: 657
    ))
  }

  @Test("Hashable treats duplicate anatomy values as one set member")
  func hashableIdentity() {
    let values: Set<FontAnatomy<Int>> = [
      FontAnatomy(
        unitsPerEm: 1000,
        ascender: 894,
        descender: -246,
        xHeight: 460,
        capHeight: 658
      ),
      FontAnatomy(
        unitsPerEm: 1000,
        ascender: 894,
        descender: -246,
        xHeight: 460,
        capHeight: 658
      ),
      FontAnatomy(
        unitsPerEm: 1000,
        ascender: 894,
        descender: -246,
        xHeight: 461,
        capHeight: 658
      ),
    ]

    #expect(values.count == 2)
  }

  @Test("Conforms to Sendable when the metric value is Sendable")
  func sendableConformance() {
    requireSendable(FontAnatomy(
      unitsPerEm: 1000,
      ascender: 894,
      descender: -246,
      xHeight: 460,
      capHeight: 658
    ))
  }

  private func requireSendable<T: Sendable>(_ value: T) {}
}
