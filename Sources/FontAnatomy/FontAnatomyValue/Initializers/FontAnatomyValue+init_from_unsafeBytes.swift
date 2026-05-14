import CFreeType
import Foundation

extension FontAnatomyValue {
  public init(unsafeBytes bytes: UnsafeRawBufferPointer) throws {
    var library: FT_Library?
    var error = FT_Init_FreeType(&library)
    guard error == 0 else { throw Error.ftInitFailure(code: Int32(error)) }
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

    self = Self(
      unitsPerEm: Double(face.pointee.units_per_EM),
      ascender: Double(face.pointee.ascender),
      descender: Double(face.pointee.descender),
      xHeight: Double(os2.sxHeight),
      capHeight: Double(os2.sCapHeight)
    )
  }

}
