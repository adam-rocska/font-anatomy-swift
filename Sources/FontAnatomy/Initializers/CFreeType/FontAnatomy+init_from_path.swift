import Foundation

extension FontAnatomy {
  public init(_ path: String) throws {
    try self.init(URL(fileURLWithPath: path))
  }
}
