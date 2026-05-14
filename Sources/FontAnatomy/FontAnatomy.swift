public struct FontAnatomy<Value>: Sendable
where Value: Sendable {
  public var unitsPerEm: Value
  public var ascender: Value
  public var descender: Value
  public var xHeight: Value
  public var capHeight: Value
}
