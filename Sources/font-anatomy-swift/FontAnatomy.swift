public protocol FontAnatomy {
  associatedtype Value

  // font?: Font,
  var unitsPerEm: Value { get }
  var ascender: Value { get }
  var descender: Value { get }
  var xHeight: Value { get }
  var capHeight: Value { get }
}
