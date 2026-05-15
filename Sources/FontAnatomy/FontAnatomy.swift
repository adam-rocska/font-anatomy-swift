public struct FontAnatomy<Value>: Sendable
where Value: Sendable {
  public let unitsPerEm: Value
  public let ascender: Value
  public let descender: Value
  public let xHeight: Value
  public let capHeight: Value

  public init(
    unitsPerEm: Value,
    ascender: Value,
    descender: Value,
    xHeight: Value,
    capHeight: Value
  ) {
    self.unitsPerEm = unitsPerEm
    self.ascender = ascender
    self.descender = descender
    self.xHeight = xHeight
    self.capHeight = capHeight
  }
}

extension FontAnatomy: Codable where Value: Codable {}
extension FontAnatomy: Equatable where Value: Equatable {}
extension FontAnatomy: Hashable where Value: Hashable {}
