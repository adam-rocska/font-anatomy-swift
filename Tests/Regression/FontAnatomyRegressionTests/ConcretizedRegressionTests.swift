import FontAnatomyTestSupport
import Foundation
import Testing
@testable import FontAnatomy

@Suite("Concretized regressions")
struct ConcretizedRegressionTests {
  @Test(
    "Sets every requested metric to the exact requested value, even after lossy division",
    arguments: FontAnatomyMetricUnderTest.allCases
  )
  func requestedMetricIsExact(metric: FontAnatomyMetricUnderTest) {
    let anatomy = FontAnatomy<Double>(
      unitsPerEm: 997,
      ascender: 853,
      descender: -307,
      xHeight: 558,
      capHeight: 701
    )
    let requestedValue = metric == .descender ? -12.0 : 12.0
    let result = anatomy.concretized(metric.keyPath(), as: requestedValue)

    #expect(metric.value(from: result) == requestedValue)
  }

  @Test("Preserves all non-selected metric proportions while setting x-height exactly")
  func preservesProportionsAroundExactXHeight() {
    let anatomy = FontAnatomy<Double>(
      unitsPerEm: 1000,
      ascender: 1050,
      descender: -350,
      xHeight: 558,
      capHeight: 705
    )
    let result = anatomy.concretized(\.xHeight, as: 12)

    #expect(result.xHeight == 12)
    #expect(isClose(result.unitsPerEm, 1000 * (12 / 558)))
    #expect(isClose(result.ascender, 1050 * (12 / 558)))
    #expect(isClose(result.descender, -350 * (12 / 558)))
    #expect(isClose(result.capHeight, 705 * (12 / 558)))
  }

  @Test("Keeps descender negative when concretizing by a positive x-height")
  func keepsDescenderNegative() {
    let result = FontAnatomy<Double>(
      unitsPerEm: 1000,
      ascender: 1050,
      descender: -350,
      xHeight: 558,
      capHeight: 705
    ).concretized(\.xHeight, as: 12)

    #expect(result.descender < 0)
  }
}

private func isClose(_ actual: Double, _ expected: Double, tolerance: Double = 1e-12) -> Bool {
  abs(actual - expected) <= tolerance
}
