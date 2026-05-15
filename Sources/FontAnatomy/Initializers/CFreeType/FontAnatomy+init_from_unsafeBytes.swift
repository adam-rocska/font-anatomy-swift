import CFreeType
import Foundation

extension FontAnatomy where Value: Numeric {
  public init(_ bytes: UnsafeRawBufferPointer) throws {
    var library: FT_Library?
    var error = FT_Init_FreeType(&library)
    guard error == 0 else {
      throw Error.ftInitFailure(code: Int32(error))
    }
    defer { if let library { FT_Done_FreeType(library) } }

    guard let baseAddress = bytes.baseAddress else {
      throw Error.ftCantOpenResource
    }

    var face: FT_Face?
    error = FT_New_Memory_Face(
      library,
      baseAddress.assumingMemoryBound(to: FT_Byte.self),
      FT_Long(bytes.count),
      0,
      &face
    )
    guard error == 0, let face else {
      throw Error.ftLoadFailure(code: Int32(error))
    }
    defer { FT_Done_Face(face) }

    guard let os2Table = FT_Get_Sfnt_Table(face, FT_SFNT_OS2) else {
      throw Error.missingOS2Table
    }
    let os2 = os2Table.assumingMemoryBound(to: TT_OS2.self).pointee

    guard
      let unitsPerEm = Value(exactly: face.pointee.units_per_EM),
      let ascender = Value(exactly: face.pointee.ascender),
      let descender = Value(exactly: face.pointee.descender),
      let xHeight = Value(exactly: os2.sxHeight),
      let capHeight = Value(exactly: os2.sCapHeight)
    else {
      throw Error.attributeTypeCastFailure
    }

    self = Self(
      unitsPerEm: unitsPerEm,
      ascender: ascender,
      descender: descender,
      xHeight: xHeight,
      capHeight: capHeight
    )
  }

}
