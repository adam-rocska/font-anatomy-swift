import Foundation

extension Data {
  internal func uInt16(at offset: Index) -> UInt16? {
    guard offset >= 0, count >= offset + 2 else { return nil }

    let firstIndex = index(startIndex, offsetBy: offset)
    let secondIndex = index(after: firstIndex)

    return UInt16(self[firstIndex]) << 8 | UInt16(self[secondIndex])
  }

  internal func int16(at offset: Index) -> Int16? {
    uInt16(at: offset).map { Int16(bitPattern: $0) }
  }

}
