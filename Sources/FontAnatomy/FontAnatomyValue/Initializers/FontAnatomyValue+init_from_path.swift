import Foundation

extension FontAnatomyValue {
  public init(path: String) throws {
    try self.init(url: URL(fileURLWithPath: path))
  }
}
