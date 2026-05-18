import Foundation
import CFreeType
import CWOFF2

extension FontAnatomy where Value: Numeric {
  public init(_ bytes: UnsafeRawBufferPointer) throws {
    if let decompressed = try bytes.decompressedWOFF2Data() {
      self = try decompressed.withUnsafeBytes {
        try Self(freeTypeBytes: $0)
      }
      return
    }

    try self.init(freeTypeBytes: bytes)
  }

  private init(freeTypeBytes bytes: UnsafeRawBufferPointer) throws {
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
    let horizontalHeader = FT_Get_Sfnt_Table(face, FT_SFNT_HHEA)?
      .assumingMemoryBound(to: TT_HoriHeader.self)
      .pointee

    guard
      let unitsPerEm = Value(exactly: face.pointee.units_per_EM),
      let ascender = Value(exactly: horizontalHeader?.Ascender ?? face.pointee.ascender),
      let descender = Value(exactly: horizontalHeader?.Descender ?? face.pointee.descender),
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

private extension UnsafeRawBufferPointer {
  func decompressedWOFF2Data() throws -> Data? {
    guard isWOFF2 else { return nil }

    var output = CWOFF2Data()
    let status = CWOFF2Decompress(
      baseAddress?.assumingMemoryBound(to: UInt8.self),
      count,
      &output
    )

    guard status == CWOFF2Success else {
      throw FontAnatomyError.woff2DecompressionFailure(code: Int32(status.rawValue))
    }

    defer { CWOFF2DataFree(output) }
    return Data(bytes: output.bytes, count: output.count)
  }

  var isWOFF2: Bool {
    guard count >= 4 else { return false }
    guard let bytes = baseAddress?.assumingMemoryBound(to: UInt8.self) else {
      return false
    }

    return bytes[0] == 0x77
      && bytes[1] == 0x4F
      && bytes[2] == 0x46
      && bytes[3] == 0x32
  }
}
