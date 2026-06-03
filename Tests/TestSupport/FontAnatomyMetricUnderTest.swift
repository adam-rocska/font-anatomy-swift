import FontAnatomy
import Foundation

public enum FontAnatomyMetricUnderTest: CaseIterable, CustomStringConvertible, Sendable {
  case unitsPerEm
  case ascender
  case descender
  case xHeight
  case capHeight

  public var description: String {
    switch self {
    case .unitsPerEm: "unitsPerEm"
    case .ascender: "ascender"
    case .descender: "descender"
    case .xHeight: "xHeight"
    case .capHeight: "capHeight"
    }
  }

  public func keyPath<Value: Sendable>() -> KeyPath<FontAnatomy<Value>, Value> {
    switch self {
    case .unitsPerEm: \.unitsPerEm
    case .ascender: \.ascender
    case .descender: \.descender
    case .xHeight: \.xHeight
    case .capHeight: \.capHeight
    }
  }

  public func value<Value: Sendable>(from anatomy: FontAnatomy<Value>) -> Value {
    anatomy[keyPath: keyPath()]
  }
}
