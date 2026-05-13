import CFreeType
import Foundation

public enum FontAnatomyMetric: String, CaseIterable, Sendable {
  case unitsPerEm
  case ascender
  case descender
  case xHeight
  case capHeight
}

public struct FontAnatomy: Codable, Equatable, Sendable {
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

public func relativize(_ basedOn: FontAnatomyMetric, _ anatomy: FontAnatomy) -> FontAnatomy {
  let basis = anatomy[basedOn]

  return FontAnatomy(
    unitsPerEm: anatomy.unitsPerEm / basis,
    ascender: anatomy.ascender / basis,
    descender: anatomy.descender / basis,
    xHeight: anatomy.xHeight / basis,
    capHeight: anatomy.capHeight / basis
  )
}

public func concretize(
  _ archetype: FontAnatomy,
  _ attribute: FontAnatomyMetric,
  _ value: Double
) -> FontAnatomy {
  let proportion = value / archetype[attribute]
  var result = FontAnatomy(
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
  _ base: FontAnatomy,
  _ anatomy: FontAnatomy,
  _ field: FontAnatomyMetric
) -> FontAnatomy {
  concretize(anatomy, field, base[field])
}

public struct FreeTypeVersion: Equatable, Sendable, CustomStringConvertible {
  public var major: Int
  public var minor: Int
  public var patch: Int

  public var description: String {
    "\(major).\(minor).\(patch)"
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

  public var version: FreeTypeVersion {
    var major: FT_Int = 0
    var minor: FT_Int = 0
    var patch: FT_Int = 0

    FT_Library_Version(library, &major, &minor, &patch)

    return FreeTypeVersion(
      major: Int(major),
      minor: Int(minor),
      patch: Int(patch)
    )
  }

  public func anatomy(fromFontData data: Data) throws -> FontAnatomy {
    try data.withUnsafeBytes { bytes in
      try anatomy(fromUnsafeBytes: bytes)
    }
  }

  public func anatomy(fromFontBytes bytes: [UInt8]) throws -> FontAnatomy {
    try bytes.withUnsafeBytes { bytes in
      try anatomy(fromUnsafeBytes: bytes)
    }
  }

  private func anatomy(fromUnsafeBytes bytes: UnsafeRawBufferPointer) throws -> FontAnatomy {
    guard let baseAddress = bytes.baseAddress else {
      throw FontAnatomyError.fontFaceLoadFailed(code: Int32(FT_Err_Cannot_Open_Resource))
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

    return FontAnatomy(
      unitsPerEm: Double(face.pointee.units_per_EM),
      ascender: Double(face.pointee.ascender),
      descender: Double(face.pointee.descender),
      xHeight: Double(os2.sxHeight),
      capHeight: Double(os2.sCapHeight)
    )
  }

  public func anatomy(fromFontFile url: URL) throws -> FontAnatomy {
    try anatomy(fromFontData: Data(contentsOf: url))
  }
}

public func fromFontBinary(_ data: Data) throws -> FontAnatomy {
  try FreeTypeLibrary().anatomy(fromFontData: data)
}

public func fromFontBinary(_ bytes: [UInt8]) throws -> FontAnatomy {
  try FreeTypeLibrary().anatomy(fromFontBytes: bytes)
}

public func fromFontFile(_ url: URL) throws -> FontAnatomy {
  try FreeTypeLibrary().anatomy(fromFontFile: url)
}
