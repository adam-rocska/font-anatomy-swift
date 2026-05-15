import Foundation

public enum FontAnatomyFixture {
  public static func libertinusSansRegularURL() throws -> URL {
    guard let url = Bundle.module.url(
      forResource: "LibertinusSans-Regular",
      withExtension: "ttf",
      subdirectory: "Fixtures"
    ) else {
      throw FontAnatomyFixtureError.missingResource("LibertinusSans-Regular.ttf")
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
