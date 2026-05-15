import FontAnatomyTestSupport
import Foundation
import Testing
@testable import FontAnatomy

@Suite("FloatingPoint edge cases")
struct FloatingPointEdgeCaseTests {
  @Test("Relativize against a negative descender basis preserves algebraic signs")
  func relativeAgainstNegativeBasis() {
    let anatomy = FontAnatomy<Double>(
      unitsPerEm: 1000,
      ascender: 800,
      descender: -200,
      xHeight: 500,
      capHeight: 700
    )
    let result = anatomy.relative(to: \.descender)

    #expect(result.unitsPerEm == -5)
    #expect(result.ascender == -4)
    #expect(result.descender == 1)
    #expect(result.xHeight == -2.5)
    #expect(result.capHeight == -3.5)
  }

  @Test("NaN basis propagates through relative anatomy")
  func relativeWithNaNBasis() {
    let result = FontAnatomy<Double>(
      unitsPerEm: 1000,
      ascender: 800,
      descender: -200,
      xHeight: .nan,
      capHeight: 700
    ).relative(to: \.xHeight)

    #expect(result.unitsPerEm.isNaN)
    #expect(result.ascender.isNaN)
    #expect(result.descender.isNaN)
    #expect(result.xHeight.isNaN)
    #expect(result.capHeight.isNaN)
  }

  @Test("Infinite basis follows IEEE division rules")
  func relativeWithInfiniteBasis() {
    let result = FontAnatomy<Double>(
      unitsPerEm: .infinity,
      ascender: 800,
      descender: -200,
      xHeight: 500,
      capHeight: 700
    ).relative(to: \.unitsPerEm)

    #expect(result.unitsPerEm.isNaN)
    #expect(result.ascender == 0)
    #expect(result.descender == 0)
    #expect(result.descender.sign == .minus)
    #expect(result.xHeight == 0)
    #expect(result.capHeight == 0)
  }

  @Test("Infinite concrete value propagates through concretized anatomy")
  func concretizedWithInfiniteValue() {
    let result = FontAnatomy<Double>(
      unitsPerEm: 1000,
      ascender: 800,
      descender: -200,
      xHeight: 500,
      capHeight: 700
    ).concretized(\.xHeight, as: .infinity)

    #expect(result.unitsPerEm == .infinity)
    #expect(result.ascender == .infinity)
    #expect(result.descender == -.infinity)
    #expect(result.xHeight == .infinity)
    #expect(result.capHeight == .infinity)
  }

  @Test("Signed zero concrete value preserves zero signs from multiplication")
  func concretizedWithSignedZero() {
    let result = FontAnatomy<Double>(
      unitsPerEm: 1000,
      ascender: 800,
      descender: -200,
      xHeight: 500,
      capHeight: 700
    ).concretized(\.xHeight, as: -0.0)

    #expect(result.unitsPerEm == 0)
    #expect(result.unitsPerEm.sign == .minus)
    #expect(result.ascender == 0)
    #expect(result.ascender.sign == .minus)
    #expect(result.descender == 0)
    #expect(result.descender.sign == .plus)
    #expect(result.xHeight == 0)
    #expect(result.xHeight.sign == .minus)
    #expect(result.capHeight == 0)
    #expect(result.capHeight.sign == .minus)
  }

  @Test("Subnormal-scale values preserve finite ratios")
  func subnormalScaleRatios() {
    let anatomy = FontAnatomy<Double>(
      unitsPerEm: 1e-300,
      ascender: 8e-301,
      descender: -2e-301,
      xHeight: 5e-301,
      capHeight: 7e-301
    )
    let result = anatomy.relative(to: \.unitsPerEm)

    #expect(isClose(result.unitsPerEm, 1))
    #expect(isClose(result.ascender, 0.8))
    #expect(isClose(result.descender, -0.2))
    #expect(isClose(result.xHeight, 0.5))
    #expect(isClose(result.capHeight, 0.7))
  }
}

private func isClose(_ actual: Double, _ expected: Double, tolerance: Double = 1e-12) -> Bool {
  abs(actual - expected) <= tolerance
}
