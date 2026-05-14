import CFreeType
import Foundation

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
    if let library { FT_Done_FreeType(library) }
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
