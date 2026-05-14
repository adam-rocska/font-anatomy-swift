import Foundation

extension FontAnatomyValue {
  public init(_ path: String) throws {
    try self.init(URL(fileURLWithPath: path))
  }
}
