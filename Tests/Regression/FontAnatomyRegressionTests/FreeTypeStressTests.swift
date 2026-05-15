import FontAnatomyTestSupport
import Foundation
import Testing
@testable import FontAnatomy

@Suite("FreeType stress", .serialized, .timeLimit(.minutes(2)))
struct FreeTypeStressTests {
  @Test("Repeated Data loads keep returning stable metrics")
  func repeatedDataLoads() throws {
    let data = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())

    for _ in 0..<512 {
      #expect(try FontAnatomy<Int>(data) == expectedLibertinusStress)
    }
  }

  @Test("Repeated URL and path loads keep returning stable metrics")
  func repeatedFileLoads() throws {
    let url = try FontAnatomyFixture.libertinusSansRegularURL()

    for _ in 0..<128 {
      #expect(try FontAnatomy<Int>(url) == expectedLibertinusStress)
      #expect(try FontAnatomy<Int>(url.path) == expectedLibertinusStress)
    }
  }

  @Test("High fan-out concurrent Data loads keep returning stable metrics")
  func highFanOutConcurrentDataLoads() async throws {
    let data = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())

    try await withThrowingTaskGroup(of: FontAnatomy<Int>.self) { group in
      for _ in 0..<256 {
        group.addTask {
          try FontAnatomy<Int>(data)
        }
      }

      for try await anatomy in group {
        #expect(anatomy == expectedLibertinusStress)
      }
    }
  }
}

private let expectedLibertinusStress = FontAnatomy<Int>(
  unitsPerEm: 1000,
  ascender: 894,
  descender: -246,
  xHeight: 460,
  capHeight: 658
)
