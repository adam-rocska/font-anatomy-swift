public protocol FontAnatomy: Sendable {
  associatedtype Value: Sendable

  var unitsPerEm: Value { get }
  var ascender: Value { get }
  var descender: Value { get }
  var xHeight: Value { get }
  var capHeight: Value { get }
}
