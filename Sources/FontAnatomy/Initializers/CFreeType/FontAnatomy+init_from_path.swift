import Foundation

extension FontAnatomy where Value: Numeric {
  public init(_ path: String) throws {
    try self.init(URL(fileURLWithPath: path))
  }
}
