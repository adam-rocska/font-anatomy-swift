import Foundation

extension FontAnatomyValue {
  public enum Error: Swift.Error {
    case invalidFileUrl(URL)
    case fileContentReadFailure(URL, Swift.Error)

    /// MARK: FreeType related errors
    case ftInitFailure(code: Int32)
    case ftCantOpenResource
    case ftLoadFailure(code: Int32)
    case missingOS2Table
  }
}
