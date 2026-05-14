import Foundation

public enum FontAnatomyError: Error {
  case invalidFileUrl(URL)
  case fileContentReadFailure(URL, Error)

  /// MARK: FreeType related errors
  case ftInitFailure(code: Int32)
  case ftCantOpenResource
  case ftLoadFailure(code: Int32)
  case missingOS2Table
}

extension FontAnatomy { typealias Error = FontAnatomyError }
