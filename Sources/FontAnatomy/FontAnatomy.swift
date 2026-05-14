public struct FontAnatomy<Value>: Sendable
where Value: Sendable {
  public var unitsPerEm: Value
  public var ascender: Value
  public var descender: Value
  public var xHeight: Value
  public var capHeight: Value
}

extension FontAnatomy: Codable where Value: Codable {}
extension FontAnatomy: Equatable where Value: Equatable {}
extension FontAnatomy: Hashable where Value: Hashable {}
