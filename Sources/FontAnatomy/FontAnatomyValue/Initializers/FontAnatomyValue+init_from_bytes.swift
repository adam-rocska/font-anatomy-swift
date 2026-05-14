import Foundation

extension FontAnatomyValue {
  public init(bytes: [UInt8]) throws {
    self = try bytes.withUnsafeBytes { bytes in
      try Self(unsafeBytes: bytes)
    }
  }
}
