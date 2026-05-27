#if canImport(CoreText)
  import Foundation
  import CoreText

  extension FontAnatomy where Value: Numeric {
    public init(_ bytes: UnsafeRawBufferPointer) throws {
      guard bytes.count > 0, let baseAddress = bytes.baseAddress else {
        throw Error.ftCantOpenResource
      }

      let data = Data(bytes: baseAddress, count: bytes.count)
      try self.init(coreTextData: data)
    }

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

    private init(coreTextData data: Data) throws {
      guard let provider = CGDataProvider(data: data as CFData) else {
        throw data.isWOFF2
          ? Error.woff2DecompressionFailure(code: -1)
          : Error.ftLoadFailure(code: -1)
      }

      guard let font = CGFont(provider) else {
        throw data.isWOFF2
          ? Error.woff2DecompressionFailure(code: -1)
          : Error.ftLoadFailure(code: -1)
      }

      let unitsPerEm = font.unitsPerEm
      let size = unitsPerEm > 0 ? CGFloat(unitsPerEm) : 1
      try self.init(of: CTFontCreateWithGraphicsFont(font, size, nil, nil))
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

  private extension Data {
    var isWOFF2: Bool {
      withUnsafeBytes { bytes in
        guard bytes.count >= 4 else { return false }
        guard let baseAddress = bytes.baseAddress else { return false }

        let bytes = baseAddress.assumingMemoryBound(to: UInt8.self)
        return bytes[0] == 0x77
          && bytes[1] == 0x4F
          && bytes[2] == 0x46
          && bytes[3] == 0x32
      }
    }
  }
#endif
