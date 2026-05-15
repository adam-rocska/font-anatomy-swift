#if canImport(CoreText) && canImport(SwiftUI)
  import Foundation
  import func CoreText.CTFontCopyTable
  import func CoreText.CTFontGetAscent
  import func CoreText.CTFontGetDescent
  import func CoreText.CTFontGetSize
  import func CoreText.CTFontGetUnitsPerEm
  import typealias CoreText.CTFont
  import typealias CoreText.CTFontTableTag
  import var CoreText.kCTFontTableHead
  import var CoreText.kCTFontTableHhea
  import var CoreText.kCTFontTableOS2
  import struct SwiftUI.EnvironmentValues
  import struct SwiftUI.Font

  @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
  extension FontAnatomy where Value: Numeric {
    public init(_ font: Font) throws {
      try self.init(font, in: EnvironmentValues().fontResolutionContext)
    }

    public init(_ font: Font, in context: Font.Context) throws {
      try self.init(font.resolve(in: context))
    }

    public init(_ font: Font.Resolved) throws {
      try self.init(resolvedFont: font.ctFont)
    }

    private init(resolvedFont font: CTFont) throws {
      let head = CTFontCopyTable(font, CTFontTableTag(kCTFontTableHead), []).map
      { $0 as Data }
      let hhea = CTFontCopyTable(font, CTFontTableTag(kCTFontTableHhea), []).map
      { $0 as Data }

      guard
        let os2 = CTFontCopyTable(font, CTFontTableTag(kCTFontTableOS2), [])
          .map({ $0 as Data })
      else {
        throw Error.missingOS2Table
      }

      guard
        let unitsPerEm = head?.unsignedShort(at: 18)
          ?? UInt16(exactly: CTFontGetUnitsPerEm(font))
      else {
        throw Error.attributeTypeCastFailure
      }

      guard
        let ascender = hhea?.signedShort(at: 4)
          ?? Self.fontUnits(CTFontGetAscent(font), in: font, per: unitsPerEm),
        let descender = hhea?.signedShort(at: 6)
          ?? Self.fontUnits(-CTFontGetDescent(font), in: font, per: unitsPerEm),
        let unitsPerEm = Value(exactly: unitsPerEm),
        let ascender = Value(exactly: ascender),
        let descender = Value(exactly: descender),
        let xHeight = Value(exactly: os2.signedShort(at: 86) ?? 0),
        let capHeight = Value(exactly: os2.signedShort(at: 88) ?? 0)
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

    private static func fontUnits(
      _ value: CGFloat, in font: CTFont, per unitsPerEm: UInt16
    ) -> Int? {
      let size = CTFontGetSize(font)
      guard size != 0 else { return nil }

      let result = Double(value / size * CGFloat(unitsPerEm)).rounded()
      guard result.isFinite, result >= Double(Int.min),
        result <= Double(Int.max)
      else {
        return nil
      }

      return Int(result)
    }
  }

  extension Data {
    fileprivate func unsignedShort(at offset: Int) -> UInt16? {
      guard offset >= 0, count >= offset + 2 else { return nil }

      let firstIndex = index(startIndex, offsetBy: offset)
      let secondIndex = index(after: firstIndex)

      return UInt16(self[firstIndex]) << 8 | UInt16(self[secondIndex])
    }

    fileprivate func signedShort(at offset: Int) -> Int? {
      unsignedShort(at: offset).map { Int(Int16(bitPattern: $0)) }
    }
  }
#endif
