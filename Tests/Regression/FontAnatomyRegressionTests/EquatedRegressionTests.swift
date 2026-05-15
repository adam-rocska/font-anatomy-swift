import FontAnatomyTestSupport
import Foundation
import Testing
@testable import FontAnatomy

@Suite("Equated regressions")
struct EquatedRegressionTests {
  @Test("Uses the base anatomy for the concrete value and the target anatomy for proportions")
  func scalesTargetToBaseMetric() {
    let base = FontAnatomy<Double>(
      unitsPerEm: 24,
      ascender: 19.2,
      descender: -4.8,
      xHeight: 12,
      capHeight: 16.8
    )
    let target = FontAnatomy<Double>(
      unitsPerEm: 1000,
      ascender: 1069,
      descender: -293,
      xHeight: 558,
      capHeight: 714
    )

    let result = base.equated(with: target, by: \.xHeight)

    #expect(result.xHeight == base.xHeight)
    #expect(isClose(result.unitsPerEm, 1000 * (12 / 558)))
    #expect(isClose(result.ascender, 1069 * (12 / 558)))
    #expect(isClose(result.descender, -293 * (12 / 558)))
    #expect(isClose(result.capHeight, 714 * (12 / 558)))
  }

  @Test(
    "Equated matches target.concretized for every metric",
    arguments: FontAnatomyMetricUnderTest.allCases
  )
  func equatedMatchesTargetConcretized(metric: FontAnatomyMetricUnderTest) {
    let base = FontAnatomy<Double>(
      unitsPerEm: 2000,
      ascender: 1637,
      descender: -412,
      xHeight: 733,
      capHeight: 1091
    )
    let target = FontAnatomy<Double>(
      unitsPerEm: 997,
      ascender: 853,
      descender: -307,
      xHeight: 558,
      capHeight: 701
    )

    let equated = base.equated(with: target, by: metric.keyPath())
    let concretized = target.concretized(
      metric.keyPath(),
      as: metric.value(from: base)
    )

    expectClose(equated, concretized)
    #expect(metric.value(from: equated) == metric.value(from: base))
  }
}

private func expectClose(_ actual: FontAnatomy<Double>, _ expected: FontAnatomy<Double>) {
  #expect(isClose(actual.unitsPerEm, expected.unitsPerEm))
  #expect(isClose(actual.ascender, expected.ascender))
  #expect(isClose(actual.descender, expected.descender))
  #expect(isClose(actual.xHeight, expected.xHeight))
  #expect(isClose(actual.capHeight, expected.capHeight))
}

private func isClose(_ actual: Double, _ expected: Double, tolerance: Double = 1e-12) -> Bool {
  abs(actual - expected) <= tolerance
}
