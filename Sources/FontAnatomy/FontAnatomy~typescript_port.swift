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

public func relativize(
  _ basedOn: FontAnatomyMetric, _ anatomy: FontAnatomy_portedSlop
) -> FontAnatomy_portedSlop {
  let basis = anatomy[basedOn]

  return FontAnatomy_portedSlop(
    unitsPerEm: anatomy.unitsPerEm / basis,
    ascender: anatomy.ascender / basis,
    descender: anatomy.descender / basis,
    xHeight: anatomy.xHeight / basis,
    capHeight: anatomy.capHeight / basis
  )
}

public func concretize(
  _ archetype: FontAnatomy_portedSlop,
  _ attribute: FontAnatomyMetric,
  _ value: Double
) -> FontAnatomy_portedSlop {
  let proportion = value / archetype[attribute]
  var result = FontAnatomy_portedSlop(
    unitsPerEm: archetype.unitsPerEm * proportion,
    ascender: archetype.ascender * proportion,
    descender: archetype.descender * proportion,
    xHeight: archetype.xHeight * proportion,
    capHeight: archetype.capHeight * proportion
  )
  result[attribute] = value
  return result
}

public func equate(
  _ base: FontAnatomy_portedSlop,
  _ anatomy: FontAnatomy_portedSlop,
  _ field: FontAnatomyMetric
) -> FontAnatomy_portedSlop {
  concretize(anatomy, field, base[field])
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

public final class FreeTypeLibrary {
  private var library: FT_Library?

  public init() throws {
    var library: FT_Library?
    let error = FT_Init_FreeType(&library)
    guard error == 0 else {
      throw FontAnatomyError.freeTypeInitializationFailed(code: Int32(error))
    }
    self.library = library
  }

  deinit {
    if let library {
      FT_Done_FreeType(library)
    }
  }

  public func anatomy(fromFontData data: Data) throws -> FontAnatomy_portedSlop
  {
    try data.withUnsafeBytes { bytes in
      try anatomy(fromUnsafeBytes: bytes)
    }
  }

  public func anatomy(fromFontBytes bytes: [UInt8]) throws
    -> FontAnatomy_portedSlop
  {
    try bytes.withUnsafeBytes { bytes in
      try anatomy(fromUnsafeBytes: bytes)
    }
  }

  private func anatomy(fromUnsafeBytes bytes: UnsafeRawBufferPointer) throws
    -> FontAnatomy_portedSlop
  {
    guard let baseAddress = bytes.baseAddress else {
      throw FontAnatomyError.fontFaceLoadFailed(
        code: Int32(FT_Err_Cannot_Open_Resource))
    }

    var face: FT_Face?
    let error = FT_New_Memory_Face(
      library,
      baseAddress.assumingMemoryBound(to: FT_Byte.self),
      FT_Long(bytes.count),
      0,
      &face
    )

    guard error == 0, let face else {
      throw FontAnatomyError.fontFaceLoadFailed(code: Int32(error))
    }

    defer {
      FT_Done_Face(face)
    }

    guard let os2Table = FT_Get_Sfnt_Table(face, FT_SFNT_OS2) else {
      throw FontAnatomyError.missingOS2Table
    }

    let os2 = os2Table.assumingMemoryBound(to: TT_OS2.self).pointee

    return FontAnatomy_portedSlop(
      unitsPerEm: Double(face.pointee.units_per_EM),
      ascender: Double(face.pointee.ascender),
      descender: Double(face.pointee.descender),
      xHeight: Double(os2.sxHeight),
      capHeight: Double(os2.sCapHeight)
    )
  }

  public func anatomy(fromFontFile url: URL) throws -> FontAnatomy_portedSlop {
    try anatomy(fromFontData: Data(contentsOf: url))
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
