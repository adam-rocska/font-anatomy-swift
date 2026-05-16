#if canImport(CoreText)
  import Foundation
  import CoreText

  extension FontAnatomy where Value: Numeric {
    public init(of font: CTFont) throws {
      guard let os2 = font.os2Table else {
        throw Error.missingOS2Table
      }

      guard
        let unitsPerEm = font.unitsPerEm,
        let ascender = font.horizontalHeaderTable?.int16(at: 4)
          ?? font.asUnit(CTFontGetAscent(font)),
        let descender = font.horizontalHeaderTable?.int16(at: 6)
          ?? font.asUnit(-CTFontGetDescent(font)),
        let xHeight = os2.int16(at: 86),
        let capHeight = os2.int16(at: 88),

        let unitsPerEm = Value(exactly: unitsPerEm),
        let ascender = Value(exactly: ascender),
        let descender = Value(exactly: descender),
        let xHeight = Value(exactly: xHeight),
        let capHeight = Value(exactly: capHeight)
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

  extension CTFont {
    func asUnit(_ value: CGFloat) -> Int16? {
      let size = CTFontGetSize(self)
      guard size != 0 else { return nil }
      guard let unitsPerEm = unitsPerEm else { return nil }

      let result = Double(value / size * CGFloat(unitsPerEm)).rounded()

      guard result.isFinite else { return nil }
      guard result >= Double(Int.min) else { return nil }
      guard result <= Double(Int.max) else { return nil }

      return Int16(result)
    }

    var headerTable: Data? {
      CTFontCopyTable(
        self,
        CTFontTableTag(kCTFontTableHead),
        []
      ) as? Data
    }

    var horizontalHeaderTable: Data? {
      CTFontCopyTable(
        self,
        CTFontTableTag(kCTFontTableHhea),
        []
      ) as? Data
    }

    var os2Table: Data? {
      CTFontCopyTable(
        self,
        CTFontTableTag(kCTFontTableOS2),
        []
      ) as? Data
    }

    var unitsPerEm: UInt16? {
      if let unitsPerEm = headerTable?.uInt16(at: 18) {
        return unitsPerEm
      }
      return UInt16(
        exactly: CTFontGetUnitsPerEm(self)
      )
    }
  }
#endif
