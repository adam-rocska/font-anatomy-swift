import Foundation

extension FontAnatomyValue {
  public init(data: Data) throws {
    self = try data.withUnsafeBytes { bytes in
      try Self(unsafeBytes: bytes)
    }
  }
}
