#if canImport(SwiftUI) && canImport(CoreText)
  import Foundation
  import SwiftUI

  #if DEBUG
    import os
    private let logger = Logger(
      subsystem: "FontAnatomy",
      category: "SwiftUI"
    )
  #endif

  @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
  extension FontAnatomy where Value: Numeric {
    public init(of font: Font, in context: Font.Context) throws {
      try self.init(of: font.resolve(in: context))
    }

    public init(of font: Font.Resolved) throws {
      try self.init(of: font.ctFont)
    }
  }

  extension EnvironmentValues {
    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
    public var fontAnatomy: FontAnatomy<CGFloat>? {
      guard let font = font else { return nil }
      do {
        let anatomy = try FontAnatomy<CGFloat>(
          of: font,
          in: fontResolutionContext
        )
        return anatomy
      } catch {
        #if DEBUG
          logger.debug("Failed to resolve font anatomy: \(error)")
        #endif
        return nil
      }
    }
  }
#endif
