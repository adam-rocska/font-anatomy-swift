import Foundation

extension FontAnatomy where Value: Numeric {
  public init(_ data: Data) throws {
    self = try data.withUnsafeBytes { try Self($0) }
  }
}
