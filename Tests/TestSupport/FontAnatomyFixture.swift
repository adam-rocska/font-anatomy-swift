import Foundation
import FontAnatomy

public enum FontAnatomyFixture {
  public static func libertinusSansRegularURL() throws -> URL {
    try requiredURL(
      forResource: "LibertinusSans-Regular",
      withExtension: "ttf"
    )
  }

  public static func notoSerifVariableURL() throws -> URL {
    try requiredURL(
      forResource: "NotoSerif-VariableFont_wdth,wght",
      withExtension: "ttf"
    )
  }

  public static func atkinsonHyperlegibleWOFF2URL() throws -> URL {
    try requiredURL(
      forResource: "AtkinsonHyperlegibleNextVF-Variable",
      withExtension: "woff2"
    )
  }

  public static func url(for fixture: FontAnatomyCorpusFixture) throws -> URL {
    try requiredURL(
      forResource: fixture.resourceName,
      withExtension: fixture.fileExtension
    )
  }

  public static func optionalFixtureURLs(withExtension fileExtension: String) -> [URL] {
    Bundle.module.urls(
      forResourcesWithExtension: fileExtension,
      subdirectory: "Fixtures"
    ) ?? []
  }

  public static func fixtureReadmeURL() throws -> URL {
    try requiredURL(
      forResource: "README",
      withExtension: "md"
    )
  }

  private static func requiredURL(
    forResource name: String,
    withExtension fileExtension: String
  ) throws -> URL {
    guard let url = Bundle.module.url(
      forResource: name,
      withExtension: fileExtension,
      subdirectory: "Fixtures"
    ) else {
      throw FontAnatomyFixtureError.missingResource("\(name).\(fileExtension)")
    }
    return url
  }
}

public struct FontAnatomyCorpusFixture: CustomStringConvertible, Sendable {
  public let resourceName: String
  public let fileExtension: String
  public let expected: FontAnatomy<Int>

  public var description: String {
    "\(resourceName).\(fileExtension)"
  }

  public static let allCases: [Self] = [
    Self(
      resourceName: "LibertinusSans-Regular",
      fileExtension: "ttf",
      expected: FontAnatomy(
        unitsPerEm: 1000,
        ascender: 894,
        descender: -246,
        xHeight: 460,
        capHeight: 658
      )
    ),
    Self(
      resourceName: "NotoSerif-VariableFont_wdth,wght",
      fileExtension: "ttf",
      expected: FontAnatomy(
        unitsPerEm: 1000,
        ascender: 1069,
        descender: -293,
        xHeight: 536,
        capHeight: 714
      )
    ),
    Self(
      resourceName: "RobotoMono-Medium",
      fileExtension: "ttf",
      expected: FontAnatomy(
        unitsPerEm: 2048,
        ascender: 2146,
        descender: -555,
        xHeight: 1082,
        capHeight: 1456
      )
    ),
    Self(
      resourceName: "FiraCode-Medium",
      fileExtension: "ttf",
      expected: FontAnatomy(
        unitsPerEm: 2000,
        ascender: 1980,
        descender: -644,
        xHeight: 1056,
        capHeight: 1380
      )
    ),
    Self(
      resourceName: "Inter-Medium",
      fileExtension: "ttf",
      expected: FontAnatomy(
        unitsPerEm: 2816,
        ascender: 2728,
        descender: -680,
        xHeight: 1536,
        capHeight: 2048
      )
    ),
    Self(
      resourceName: "Merriweather-Bold",
      fileExtension: "ttf",
      expected: FontAnatomy(
        unitsPerEm: 1000,
        ascender: 984,
        descender: -273,
        xHeight: 556,
        capHeight: 743
      )
    ),
    Self(
      resourceName: "Pacifico-Regular",
      fileExtension: "ttf",
      expected: FontAnatomy(
        unitsPerEm: 1000,
        ascender: 1303,
        descender: -453,
        xHeight: 460,
        capHeight: 840
      )
    ),
    Self(
      resourceName: "Poppins-Regular",
      fileExtension: "ttf",
      expected: FontAnatomy(
        unitsPerEm: 1000,
        ascender: 1050,
        descender: -350,
        xHeight: 548,
        capHeight: 698
      )
    ),
  ]
}

public enum FontAnatomyFixtureError: Error, CustomStringConvertible, Sendable {
  case missingResource(String)

  public var description: String {
    switch self {
    case let .missingResource(name):
      "Missing test fixture: \(name)"
    }
  }
}
