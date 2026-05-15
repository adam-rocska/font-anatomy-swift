import Foundation

extension FontAnatomy where Value: Numeric {
  public init(_ bytes: [UInt8]) throws {
    self = try bytes.withUnsafeBytes { try Self($0) }
  }
}
