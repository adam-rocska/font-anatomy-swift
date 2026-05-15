import FontAnatomyTestSupport
import Foundation
import Testing

@testable import FontAnatomy

@Suite("Metric transformations")
struct MetricTransformationTests {
  @Test(
    "Relativize divides every metric by the chosen basis",
    arguments: FontAnatomyMetricUnderTest.allCases
  )
  func relativizeDividesEveryMetric(metric: FontAnatomyMetricUnderTest) {
    let anatomy = sampleAnatomy
    let result = anatomy.relative(to: metric.keyPath())
    let expected = scaled(anatomy, by: 1 / metric.value(from: anatomy))

    expectClose(result, expected)
  }

  @Test(
    "Relativize sets the chosen basis metric to one",
    arguments: FontAnatomyMetricUnderTest.allCases
  )
  func relativizeSetsBasisToOne(metric: FontAnatomyMetricUnderTest) {
    let result = sampleAnatomy.relative(to: metric.keyPath())

    #expect(metric.value(from: result) == 1)
  }

  @Test(
    "Relativize static and initializer spellings match the instance spelling")
  func relativizeSpellingVariants() {
    let anatomy = sampleAnatomy

    #expect(
      FontAnatomy(relativize: anatomy, basedOn: \.unitsPerEm)
        == anatomy.relative(to: \.unitsPerEm)
    )
    #expect(
      FontAnatomy.relativizing(anatomy, basedOn: \.unitsPerEm)
        == anatomy.relative(to: \.unitsPerEm)
    )
  }

  @Test(
    "Concretized multiplies every metric by the same proportion",
    arguments: FontAnatomyMetricUnderTest.allCases
  )
  func concretizedScalesEveryMetric(metric: FontAnatomyMetricUnderTest) {
    let anatomy = sampleAnatomy
    let value = metric == .descender ? -10.0 : 10.0
    let result = anatomy.concretized(metric.keyPath(), as: value)
    let expected = scaled(anatomy, by: value / metric.value(from: anatomy))

    expectClose(result, expected)
  }

  @Test(
    "Concretized sets the chosen metric to the requested value",
    arguments: FontAnatomyMetricUnderTest.allCases
  )
  func concretizedSetsChosenMetric(metric: FontAnatomyMetricUnderTest) {
    let value = metric == .descender ? -10.0 : 10.0
    let result = sampleAnatomy.concretized(metric.keyPath(), as: value)

    #expect(metric.value(from: result) == value)
  }

  @Test(
    "Concretized static and initializer spellings match the instance spelling")
  func concretizedSpellingVariants() {
    let anatomy = sampleAnatomy

    #expect(
      FontAnatomy(concretizing: anatomy, by: \.xHeight, as: 12)
        == anatomy.concretized(\.xHeight, as: 12)
    )
    #expect(
      FontAnatomy.concretizing(anatomy, by: \.xHeight, as: 12)
        == anatomy.concretized(\.xHeight, as: 12)
    )
  }

  @Test("Concretized allows zero as the requested concrete value")
  func concretizedAllowsZeroValue() {
    let result = sampleAnatomy.concretized(\.xHeight, as: 0)

    #expect(result.unitsPerEm == 0)
    #expect(result.ascender == 0)
    #expect(result.descender == 0)
    #expect(result.descender.sign == .minus)
    #expect(result.xHeight == 0)
    #expect(result.capHeight == 0)
  }

  @Test(
    "Equated scales the target anatomy to the base metric",
    arguments: FontAnatomyMetricUnderTest.allCases
  )
  func equatedScalesTargetToBase(metric: FontAnatomyMetricUnderTest) {
    let result = baseAnatomy.equated(with: sampleAnatomy, by: metric.keyPath())
    let expected = scaled(
      sampleAnatomy,
      by: metric.value(from: baseAnatomy) / metric.value(from: sampleAnatomy)
    )

    expectClose(result, expected)
  }

  @Test(
    "Equated sets the chosen target metric to the base metric",
    arguments: FontAnatomyMetricUnderTest.allCases
  )
  func equatedSetsChosenMetricToBase(metric: FontAnatomyMetricUnderTest) {
    let result = baseAnatomy.equated(with: sampleAnatomy, by: metric.keyPath())

    #expect(metric.value(from: result) == metric.value(from: baseAnatomy))
  }

  @Test("Equated static and initializer spellings match the instance spelling")
  func equatedSpellingVariants() {
    let base = baseAnatomy
    let target = sampleAnatomy

    #expect(
      FontAnatomy(equating: base, with: target, by: \.xHeight)
        == base.equated(with: target, by: \.xHeight)
    )
    #expect(
      FontAnatomy.equating(base, with: target, by: \.xHeight)
        == base.equated(with: target, by: \.xHeight)
    )
  }

  @Test("Transforms return new values without mutating inputs")
  func transformationsDoNotMutateInputs() {
    let prototype = sampleAnatomy
    let base = baseAnatomy

    _ = prototype.relative(to: \.xHeight)
    _ = prototype.concretized(\.capHeight, as: 14)
    _ = base.equated(with: prototype, by: \.xHeight)

    #expect(prototype == sampleAnatomy)
    #expect(base == baseAnatomy)
  }

  @Test(
    "Relative and concretized round-trip original finite anatomy",
    arguments: FontAnatomyMetricUnderTest.allCases
  )
  func relativeAndConcretizedRoundTrip(metric: FontAnatomyMetricUnderTest) {
    let anatomy = sampleAnatomy
    let result =
      anatomy
      .relative(to: metric.keyPath())
      .concretized(metric.keyPath(), as: metric.value(from: anatomy))

    expectClose(result, anatomy)
  }

  @Test(
    "Concretized preserves relative proportions",
    arguments: FontAnatomyMetricUnderTest.allCases
  )
  func concretizedPreservesRelativeProportions(
    metric: FontAnatomyMetricUnderTest
  ) {
    let anatomy = sampleAnatomy
    let result = anatomy.concretized(
      metric.keyPath(), as: metric == .descender ? -13 : 13)

    expectClose(
      result.relative(to: metric.keyPath()),
      anatomy.relative(to: metric.keyPath()))
  }

  @Test("Transforms work with Float values")
  func transformsFloatValues() {
    let anatomy = FontAnatomy<Float>(
      unitsPerEm: 1000,
      ascender: 800,
      descender: -200,
      xHeight: 500,
      capHeight: 700
    )

    #expect(anatomy.relative(to: \.unitsPerEm).ascender == 0.8)
    #expect(anatomy.concretized(\.xHeight, as: 12).xHeight == 12)
    #expect(
      anatomy.equated(
        with: anatomy.concretized(\.xHeight, as: 12), by: \.xHeight
      ).xHeight == 500)
  }

  @Test("Division by a zero relative basis follows FloatingPoint semantics")
  func relativeWithZeroBasis() {
    let anatomy = FontAnatomy<Double>(
      unitsPerEm: 1000,
      ascender: 800,
      descender: -200,
      xHeight: 0,
      capHeight: 700
    )
    let result = anatomy.relative(to: \.xHeight)

    #expect(result.unitsPerEm.isInfinite)
    #expect(result.ascender.isInfinite)
    #expect(result.descender.isInfinite)
    #expect(result.xHeight.isNaN)
    #expect(result.capHeight.isInfinite)
  }

  @Test(
    "Concretizing from a zero prototype basis follows FloatingPoint semantics")
  func concretizedWithZeroPrototypeBasis() {
    let anatomy = FontAnatomy<Double>(
      unitsPerEm: 1000,
      ascender: 800,
      descender: -200,
      xHeight: 0,
      capHeight: 700
    )
    let result = anatomy.concretized(\.xHeight, as: 12)

    #expect(result.unitsPerEm.isInfinite)
    #expect(result.ascender.isInfinite)
    #expect(result.descender.isInfinite)
    #expect(result.xHeight == 12)
    #expect(result.capHeight.isInfinite)
  }

  @Test(
    "Very small and very large finite values do not collapse ordinary ratios")
  func extremeFiniteValues() {
    let anatomy = FontAnatomy<Double>(
      unitsPerEm: 1e150,
      ascender: 8e149,
      descender: -2e149,
      xHeight: 5e149,
      capHeight: 7e149
    )

    expectClose(
      anatomy.relative(to: \.unitsPerEm),
      FontAnatomy(
        unitsPerEm: 1,
        ascender: 0.8,
        descender: -0.2,
        xHeight: 0.5,
        capHeight: 0.7
      ))
  }
}

private let sampleAnatomy = FontAnatomy<Double>(
  unitsPerEm: 1000,
  ascender: 800,
  descender: -200,
  xHeight: 500,
  capHeight: 700
)

private let baseAnatomy = FontAnatomy<Double>(
  unitsPerEm: 1200,
  ascender: 900,
  descender: -300,
  xHeight: 600,
  capHeight: 750
)

private func scaled(_ source: FontAnatomy<Double>, by proportion: Double)
  -> FontAnatomy<Double>
{
  FontAnatomy(
    unitsPerEm: source.unitsPerEm * proportion,
    ascender: source.ascender * proportion,
    descender: source.descender * proportion,
    xHeight: source.xHeight * proportion,
    capHeight: source.capHeight * proportion
  )
}

private func expectClose(
  _ actual: FontAnatomy<Double>,
  _ expected: FontAnatomy<Double>,
  absoluteTolerance: Double = 1e-12,
  relativeTolerance: Double = 1e-12
) {
  #expect(
    isClose(
      actual.unitsPerEm, expected.unitsPerEm, absoluteTolerance,
      relativeTolerance))
  #expect(
    isClose(
      actual.ascender, expected.ascender, absoluteTolerance, relativeTolerance))
  #expect(
    isClose(
      actual.descender, expected.descender, absoluteTolerance, relativeTolerance
    ))
  #expect(
    isClose(
      actual.xHeight, expected.xHeight, absoluteTolerance, relativeTolerance))
  #expect(
    isClose(
      actual.capHeight, expected.capHeight, absoluteTolerance, relativeTolerance
    ))
}

private func isClose(
  _ actual: Double,
  _ expected: Double,
  _ absoluteTolerance: Double,
  _ relativeTolerance: Double
) -> Bool {
  let scale = max(1, abs(expected))
  return abs(actual - expected)
    <= max(absoluteTolerance, relativeTolerance * scale)
}
