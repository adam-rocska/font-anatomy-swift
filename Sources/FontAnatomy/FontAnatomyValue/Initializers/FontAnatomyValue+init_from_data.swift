import Foundation

extension FontAnatomyValue {
  public init(_ data: Data) throws {
    self = try data.withUnsafeBytes { try Self($0) }
  }
}
