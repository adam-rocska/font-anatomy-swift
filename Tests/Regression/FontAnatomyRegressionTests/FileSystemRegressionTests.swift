import FontAnatomyTestSupport
import Foundation
import Testing
@testable import FontAnatomy

@Suite("Filesystem regressions", .serialized, .timeLimit(.minutes(1)))
struct FileSystemRegressionTests {
  @Test("Loads fonts from paths containing spaces")
  func loadsPathContainingSpaces() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let directory = try temporaryDirectory.createDirectory("directory with spaces")
    let url = directory.appendingPathComponent("Libertinus Sans Regular.ttf")
    try copyLibertinus(to: url)

    #expect(try FontAnatomy<Int>(url) == expectedLibertinus)
    #expect(try FontAnatomy<Int>(url.path) == expectedLibertinus)
  }

  @Test("Loads fonts from paths containing non-ASCII Unicode scalars")
  func loadsUnicodePath() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let directory = try temporaryDirectory.createDirectory("unicode-\u{00E1}-\u{03A9}-\u{65E5}")
    let url = directory.appendingPathComponent("Libertinus-\u{00E1}\u{03A9}\u{65E5}.ttf")
    try copyLibertinus(to: url)

    #expect(try FontAnatomy<Int>(url) == expectedLibertinus)
    #expect(try FontAnatomy<Int>(url.path) == expectedLibertinus)
  }

  @Test("Loads fonts from relative file paths")
  func loadsRelativePath() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let url = temporaryDirectory.appending("relative.ttf")
    try copyLibertinus(to: url)

    let fileManager = FileManager.default
    let originalDirectory = fileManager.currentDirectoryPath
    defer { fileManager.changeCurrentDirectoryPath(originalDirectory) }
    #expect(fileManager.changeCurrentDirectoryPath(temporaryDirectory.url.path))

    #expect(try FontAnatomy<Int>("relative.ttf") == expectedLibertinus)
  }

  @Test("Loads fonts through symbolic links when supported")
  func loadsSymlink() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let target = temporaryDirectory.appending("target.ttf")
    let link = temporaryDirectory.appending("link.ttf")
    try copyLibertinus(to: target)

    do {
      try FileManager.default.createSymbolicLink(at: link, withDestinationURL: target)
    } catch {
      return
    }

    #expect(try FontAnatomy<Int>(link) == expectedLibertinus)
  }

  @Test("Directory URLs fail as file content read failures")
  func directoryURLFailsAsReadFailure() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let directory = try temporaryDirectory.createDirectory("font.ttf")

    do {
      _ = try FontAnatomy<Int>(directory)
      Issue.record("Expected directory URL to fail while reading file contents")
    } catch FontAnatomyError.fileContentReadFailure(let url, _) {
      #expect(url == directory)
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Unreadable files fail as read failures when the platform enforces permissions")
  func unreadableFileFailsAsReadFailureWhenPermissionsApply() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let url = temporaryDirectory.appending("unreadable.ttf")
    try copyLibertinus(to: url)

    try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: url.path)
    defer {
      try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
    }

    do {
      _ = try FontAnatomy<Int>(url)
    } catch FontAnatomyError.fileContentReadFailure(let failedURL, _) {
      #expect(failedURL == url)
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }
}

private let expectedLibertinus = FontAnatomy<Int>(
  unitsPerEm: 1000,
  ascender: 894,
  descender: -246,
  xHeight: 460,
  capHeight: 658
)

private func copyLibertinus(to destination: URL) throws {
  try FileManager.default.copyItem(
    at: FontAnatomyFixture.libertinusSansRegularURL(),
    to: destination
  )
}
