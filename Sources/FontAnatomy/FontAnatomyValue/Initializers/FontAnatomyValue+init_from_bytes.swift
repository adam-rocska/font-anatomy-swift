import Foundation

extension FontAnatomyValue {
  public init(_ bytes: [UInt8]) throws {
    self = try bytes.withUnsafeBytes { try Self($0) }
  }
}
