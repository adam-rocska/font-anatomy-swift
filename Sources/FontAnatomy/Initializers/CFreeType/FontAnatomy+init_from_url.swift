import Foundation

extension FontAnatomy where Value: Numeric {
  public init(_ url: URL) throws {
    guard url.isFileURL else { throw Error.invalidFileUrl(url) }

    let data: Data
    do {
      data = try Data(contentsOf: url)
    } catch {
      throw Error.fileContentReadFailure(url, error)
    }

    try self.init(data)
  }
}
