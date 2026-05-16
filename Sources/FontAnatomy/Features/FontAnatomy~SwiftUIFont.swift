#if canImport(SwiftUI) && canImport(CoreText)
  import Foundation
  import SwiftUI

  @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
  extension FontAnatomy where Value: Numeric {
    public init(_ font: Font, in context: Font.Context) throws {
      try self.init(font.resolve(in: context))
    }

    public init(_ font: Font.Resolved) throws {
      try self.init(of: font.ctFont)
    }
  }
#endif
