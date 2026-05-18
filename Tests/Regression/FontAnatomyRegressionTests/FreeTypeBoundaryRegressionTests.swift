import FontAnatomyTestSupport
import Foundation
import Testing
@testable import FontAnatomy

@Suite("FreeType boundary regressions", .timeLimit(.minutes(1)))
struct FreeTypeBoundaryRegressionTests {
  @Test(
    "Truncated valid font prefixes fail without crashing",
    arguments: [0, 1, 2, 3, 4, 8, 12, 16, 32, 64, 128, 256, 512, 1024]
  )
  func truncatedPrefixesFail(length: Int) throws {
    let font = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())
    let prefix = Array(font.prefix(length))

    expectFreeTypeRejection(prefix)
  }

  @Test("Almost-complete truncated fonts either reject or extract stable metrics")
  func almostCompleteTruncatedFontDoesNotCrash() throws {
    let font = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())

    let truncated = Array(font.dropLast())
    do {
      let anatomy = try FontAnatomy<Int>(truncated)
      #expect(anatomy == FontAnatomy(
        unitsPerEm: 1000,
        ascender: 894,
        descender: -246,
        xHeight: 460,
        capHeight: 658
      ))
    } catch FontAnatomyError.ftCantOpenResource {
    } catch FontAnatomyError.ftLoadFailure {
    } catch FontAnatomyError.missingOS2Table {
    } catch FontAnatomyError.attributeTypeCastFailure {
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("Mutated font signatures fail without crashing")
  func mutatedSignaturesFail() throws {
    let font = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())
    let signatures: [[UInt8]] = [
      [0x4F, 0x54, 0x54, 0x4F],
      [0x77, 0x4F, 0x46, 0x32],
      [0x74, 0x74, 0x63, 0x66],
      [0xDE, 0xAD, 0xBE, 0xEF],
    ]

    for signature in signatures {
      var bytes = Array(font)
      bytes.replaceSubrange(0..<4, with: signature)
      expectFreeTypeRejection(bytes)
    }
  }

  @Test("Deterministic random byte buffers fail without crashing")
  func randomBuffersFail() {
    var generator = LinearCongruentialGenerator(seed: 0x5EED)

    for length in stride(from: 1, through: 2048, by: 97) {
      let bytes = (0..<length).map { _ in generator.nextByte() }
      expectFreeTypeRejection(bytes)
    }
  }

  @Test("Single-byte mutations across the table directory do not crash")
  func tableDirectoryMutationsDoNotCrash() throws {
    let font = try Data(contentsOf: FontAnatomyFixture.libertinusSansRegularURL())
    let original = Array(font)

    for offset in stride(from: 0, to: min(original.count, 256), by: 13) {
      var mutated = original
      mutated[offset] = mutated[offset] ^ 0xFF

      do {
        _ = try FontAnatomy<Int>(mutated)
      } catch FontAnatomyError.ftCantOpenResource {
      } catch FontAnatomyError.ftLoadFailure {
      } catch FontAnatomyError.missingOS2Table {
      } catch FontAnatomyError.attributeTypeCastFailure {
      } catch {
        Issue.record("Unexpected error for mutation at \(offset): \(error)")
      }
    }
  }
}

private struct LinearCongruentialGenerator {
  private var state: UInt64

  init(seed: UInt64) {
    state = seed
  }

  mutating func nextByte() -> UInt8 {
    state = state &* 6_364_136_223_846_793_005 &+ 1
    return UInt8(truncatingIfNeeded: state >> 32)
  }
}

private func expectFreeTypeRejection(_ bytes: [UInt8]) {
  do {
    _ = try FontAnatomy<Int>(bytes)
    Issue.record("Expected invalid font bytes to be rejected")
  } catch FontAnatomyError.ftCantOpenResource {
  } catch FontAnatomyError.ftLoadFailure {
  } catch FontAnatomyError.missingOS2Table {
  } catch FontAnatomyError.attributeTypeCastFailure {
  } catch FontAnatomyError.woff2DecompressionFailure {
  } catch {
    Issue.record("Unexpected error: \(error)")
  }
}
