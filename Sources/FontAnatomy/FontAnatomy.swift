public struct FontAnatomy<Value>: Sendable
where Value: Sendable {
  public let unitsPerEm: Value
  public let ascender: Value
  public let descender: Value
  public let xHeight: Value
  public let capHeight: Value
}

extension FontAnatomy: Codable where Value: Codable {}
extension FontAnatomy: Equatable where Value: Equatable {}
extension FontAnatomy: Hashable where Value: Hashable {}
