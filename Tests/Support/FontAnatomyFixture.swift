import Foundation

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

  public static func optionalFixtureURLs(withExtension fileExtension: String) -> [URL] {
    Bundle.module.urls(
      forResourcesWithExtension: fileExtension,
      subdirectory: "Fixtures"
    ) ?? []
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

public enum FontAnatomyFixtureError: Error, CustomStringConvertible, Sendable {
  case missingResource(String)

  public var description: String {
    switch self {
    case let .missingResource(name):
      "Missing test fixture: \(name)"
    }
  }
}
