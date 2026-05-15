import FontAnatomyTestSupport
import Foundation
import Testing
@testable import FontAnatomy

@Suite("FreeType font loading", .timeLimit(.minutes(1)))
struct FreeTypeFontLoadingTests {
  @Test("Loads Libertinus Sans metrics from Data")
  func loadsFromData() throws {
    let data = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())

    #expect(try FontAnatomy<Int>(data) == expectedLibertinusInt)
    expectClose(try FontAnatomy<Double>(data), expectedLibertinusDouble)
  }

  @Test("Loads Libertinus Sans metrics from byte arrays")
  func loadsFromBytes() throws {
    let data = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())
    let bytes = Array(data)

    #expect(try FontAnatomy<Int>(bytes) == expectedLibertinusInt)
  }

  @Test("Loads Libertinus Sans metrics from unsafe raw bytes")
  func loadsFromUnsafeRawBytes() throws {
    let data = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())

    let anatomy = try data.withUnsafeBytes { bytes in
      try FontAnatomy<Int>(bytes)
    }

    #expect(anatomy == expectedLibertinusInt)
  }

  @Test("Loads Libertinus Sans metrics from file URLs and paths")
  func loadsFromFileURLAndPath() throws {
    let url = try FontAnatomyFixture.libertinusSansRegularURL()

    #expect(try FontAnatomy<Int>(url) == expectedLibertinusInt)
    #expect(try FontAnatomy<Int>(url.path) == expectedLibertinusInt)
  }

  @Test("Loads concurrently without sharing unsafe FreeType state")
  func loadsConcurrently() async throws {
    let data = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())

    try await withThrowingTaskGroup(of: FontAnatomy<Int>.self) { group in
      for _ in 0..<32 {
        group.addTask {
          try FontAnatomy<Int>(data)
        }
      }

      for try await anatomy in group {
        #expect(anatomy == expectedLibertinusInt)
      }
    }
  }

  @Test("Rejects non-file URLs before attempting to read bytes")
  func rejectsNonFileURLs() {
    let url = URL(string: "https://example.com/LibertinusSans-Regular.ttf")!

    do {
      _ = try FontAnatomy<Int>(url)
      Issue.record("Expected invalidFileUrl for \(url)")
    } catch FontAnatomyError.invalidFileUrl(let rejectedURL) {
      #expect(rejectedURL == url)
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Wraps file read failures with the failing URL")
  func wrapsFileReadFailures() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let url = temporaryDirectory.appending("missing.ttf")

    do {
      _ = try FontAnatomy<Int>(url)
      Issue.record("Expected fileContentReadFailure for \(url)")
    } catch FontAnatomyError.fileContentReadFailure(let failedURL, _) {
      #expect(failedURL == url)
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test(
    "Rejects invalid byte buffers without crashing",
    arguments: [
      Array("not a font".utf8),
      [0x00, 0x01, 0x00, 0x00],
      [0x4F, 0x54, 0x54, 0x4F],
      [0x77, 0x4F, 0x46, 0x32],
      [],
    ] as [[UInt8]]
  )
  func rejectsInvalidByteBuffers(bytes: [UInt8]) {
    do {
      _ = try FontAnatomy<Int>(bytes)
      Issue.record("Expected FreeType to reject invalid bytes")
    } catch FontAnatomyError.ftCantOpenResource {
    } catch FontAnatomyError.ftLoadFailure {
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Rejects nil unsafe raw buffer pointers")
  func rejectsNilUnsafeRawBufferPointer() throws {
    let bytes = UnsafeRawBufferPointer(start: nil, count: 0)

    do {
      _ = try FontAnatomy<Int>(bytes)
      Issue.record("Expected nil raw buffer pointer to be rejected")
    } catch FontAnatomyError.ftCantOpenResource {
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Rejects unsigned metric value types when the font contains a negative descender")
  func rejectsUnsignedMetricValueTypes() throws {
    let data = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())

    do {
      _ = try FontAnatomy<UInt16>(data)
      Issue.record("Expected negative descender conversion to fail")
    } catch FontAnatomyError.attributeTypeCastFailure {
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Keeps exact integer metrics when loading into Float")
  func loadsIntoFloat() throws {
    let data = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())
    let anatomy = try FontAnatomy<Float>(data)

    #expect(anatomy.unitsPerEm == 1000)
    #expect(anatomy.ascender == 894)
    #expect(anatomy.descender == -246)
    #expect(anatomy.xHeight == 460)
    #expect(anatomy.capHeight == 658)
  }
}

private let expectedLibertinusInt = FontAnatomy<Int>(
  unitsPerEm: 1000,
  ascender: 894,
  descender: -246,
  xHeight: 460,
  capHeight: 658
)

private let expectedLibertinusDouble = FontAnatomy<Double>(
  unitsPerEm: 1000,
  ascender: 894,
  descender: -246,
  xHeight: 460,
  capHeight: 658
)

private func expectClose(
  _ actual: FontAnatomy<Double>,
  _ expected: FontAnatomy<Double>,
  tolerance: Double = 1e-12
) {
  #expect(abs(actual.unitsPerEm - expected.unitsPerEm) <= tolerance)
  #expect(abs(actual.ascender - expected.ascender) <= tolerance)
  #expect(abs(actual.descender - expected.descender) <= tolerance)
  #expect(abs(actual.xHeight - expected.xHeight) <= tolerance)
  #expect(abs(actual.capHeight - expected.capHeight) <= tolerance)
}
