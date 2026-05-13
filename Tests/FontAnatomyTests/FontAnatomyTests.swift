import Testing
import Foundation
@testable import FontAnatomy

@Test func initializesFreeType() throws {
  let library = try FreeTypeLibrary()

  #expect(library.version.major >= 2)
}

@Test func extractsAnatomyFromTTFBytes() throws {
  let url = Bundle.module.url(
    forResource: "LibertinusSans-Regular",
    withExtension: "ttf",
    subdirectory: "Fixtures"
  )!
  let anatomy = try fromFontFile(url)

  #expect(anatomy == FontAnatomy(
    unitsPerEm: 1000,
    ascender: 894,
    descender: -246,
    xHeight: 460,
    capHeight: 658
  ))
}

@Test func transformsAnatomyMetrics() {
  let anatomy = FontAnatomy(
    unitsPerEm: 1000,
    ascender: 800,
    descender: -200,
    xHeight: 500,
    capHeight: 700
  )

  #expect(relativize(.unitsPerEm, anatomy) == FontAnatomy(
    unitsPerEm: 1,
    ascender: 0.8,
    descender: -0.2,
    xHeight: 0.5,
    capHeight: 0.7
  ))

  #expect(concretize(anatomy, .xHeight, 12) == FontAnatomy(
    unitsPerEm: 24,
    ascender: 19.2,
    descender: -4.8,
    xHeight: 12,
    capHeight: 16.8
  ))

  #expect(equate(concretize(anatomy, .xHeight, 12), anatomy, .xHeight).xHeight == 12)
}
