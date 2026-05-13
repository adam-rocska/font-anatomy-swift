import CFreeType
import Foundation

public enum FontAnatomyMetric: String, CaseIterable, Sendable {
  case unitsPerEm
  case ascender
  case descender
  case xHeight
  case capHeight
}

public struct FontAnatomy_portedSlop: Codable, Equatable, Sendable {
  public var unitsPerEm: Double
  public var ascender: Double
  public var descender: Double
  public var xHeight: Double
  public var capHeight: Double

  public init(
    unitsPerEm: Double,
    ascender: Double,
    descender: Double,
    xHeight: Double,
    capHeight: Double
  ) {
    self.unitsPerEm = unitsPerEm
    self.ascender = ascender
    self.descender = descender
    self.xHeight = xHeight
    self.capHeight = capHeight
  }

  public subscript(metric: FontAnatomyMetric) -> Double {
    get {
      switch metric {
      case .unitsPerEm: unitsPerEm
      case .ascender: ascender
      case .descender: descender
      case .xHeight: xHeight
      case .capHeight: capHeight
      }
    }
    set {
      switch metric {
      case .unitsPerEm: unitsPerEm = newValue
      case .ascender: ascender = newValue
      case .descender: descender = newValue
      case .xHeight: xHeight = newValue
      case .capHeight: capHeight = newValue
      }
    }
  }
}

public enum FontAnatomyError: Error, Equatable, CustomStringConvertible {
  case freeTypeInitializationFailed(code: Int32)
  case fontFaceLoadFailed(code: Int32)
  case missingOS2Table

  public var description: String {
    switch self {
    case .freeTypeInitializationFailed(let code):
      "FreeType initialization failed with error code \(code)."
    case .fontFaceLoadFailed(let code):
      "FreeType could not load the font face with error code \(code)."
    case .missingOS2Table:
      "The font does not expose an OS/2 table with x-height and cap-height metrics."
    }
  }
}

public func fromFontBinary(_ data: Data) throws -> FontAnatomy_portedSlop {
  try FreeTypeLibrary().anatomy(fromFontData: data)
}

public func fromFontBinary(_ bytes: [UInt8]) throws -> FontAnatomy_portedSlop {
  try FreeTypeLibrary().anatomy(fromFontBytes: bytes)
}

public func fromFontFile(_ url: URL) throws -> FontAnatomy_portedSlop {
  try FreeTypeLibrary().anatomy(fromFontFile: url)
}
