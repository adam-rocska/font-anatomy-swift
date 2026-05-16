import Foundation
import Testing
@testable import FontAnatomy

@Suite("Data accessors")
struct DataAccessorTests {
  @Test("uInt16 reads big-endian unsigned two-byte values")
  func uInt16ReadsBigEndianUnsignedValues() {
    let cases: [([UInt8], UInt16)] = [
      ([0x00, 0x00], 0x0000),
      ([0x00, 0x01], 0x0001),
      ([0x01, 0x00], 0x0100),
      ([0x12, 0x34], 0x1234),
      ([0x7F, 0xFF], 0x7FFF),
      ([0x80, 0x00], 0x8000),
      ([0xFF, 0xFE], 0xFFFE),
      ([0xFF, 0xFF], 0xFFFF),
    ]

    for (bytes, expected) in cases {
      #expect(Data(bytes).uInt16(at: 0) == expected)
    }
  }

  @Test("uInt16 reads every valid two-byte window")
  func uInt16ReadsEveryValidWindow() {
    let data = Data([0x01, 0x23, 0x45, 0x67, 0x89])

    #expect(data.uInt16(at: 0) == 0x0123)
    #expect(data.uInt16(at: 1) == 0x2345)
    #expect(data.uInt16(at: 2) == 0x4567)
    #expect(data.uInt16(at: 3) == 0x6789)
  }

  @Test("uInt16 ignores surrounding bytes outside the requested window")
  func uInt16ReadsOnlyRequestedWindow() {
    let data = Data([0xFF, 0xEE, 0x12, 0x34, 0xDD, 0xCC])

    #expect(data.uInt16(at: 2) == 0x1234)
  }

  @Test("uInt16 rejects offsets that cannot provide two bytes")
  func uInt16RejectsOutOfBoundsOffsets() {
    #expect(Data().uInt16(at: 0) == nil)
    #expect(Data([0xAB]).uInt16(at: 0) == nil)

    let data = Data([0xAB, 0xCD])

    #expect(data.uInt16(at: -1) == nil)
    #expect(data.uInt16(at: Int.min) == nil)
    #expect(data.uInt16(at: 1) == nil)
    #expect(data.uInt16(at: 2) == nil)
    #expect(data.uInt16(at: 3) == nil)
    #expect(data.uInt16(at: Int.max - 2) == nil)
  }

  @Test("uInt16 accepts the last possible valid offset")
  func uInt16AcceptsLastValidOffset() {
    let data = Data([0x00, 0x11, 0x22, 0x33])

    #expect(data.uInt16(at: 2) == 0x2233)
    #expect(data.uInt16(at: 3) == nil)
  }

  @Test("int16 preserves signed two's-complement bit patterns")
  func int16PreservesSignedBitPatterns() {
    let cases: [([UInt8], Int16)] = [
      ([0x00, 0x00], 0),
      ([0x00, 0x01], 1),
      ([0x7F, 0xFF], Int16.max),
      ([0x80, 0x00], Int16.min),
      ([0x80, 0x01], Int16.min + 1),
      ([0xFF, 0xFE], -2),
      ([0xFF, 0xFF], -1),
    ]

    for (bytes, expected) in cases {
      #expect(Data(bytes).int16(at: 0) == expected)
    }
  }

  @Test("int16 matches the signed interpretation of uInt16")
  func int16MatchesUInt16BitPatternInterpretation() {
    let data = Data([0x00, 0x01, 0x7F, 0xFF, 0x80, 0x00, 0xFF, 0xFF])

    for offset in 0...(data.count - 2) {
      let unsigned = data.uInt16(at: offset)
      let signed = data.int16(at: offset)

      #expect(signed == unsigned.map(Int16.init(bitPattern:)))
    }
  }

  @Test("int16 rejects the same invalid offsets as uInt16")
  func int16RejectsOutOfBoundsOffsets() {
    #expect(Data().int16(at: 0) == nil)
    #expect(Data([0xAB]).int16(at: 0) == nil)

    let data = Data([0xAB, 0xCD])

    #expect(data.int16(at: -1) == nil)
    #expect(data.int16(at: Int.min) == nil)
    #expect(data.int16(at: 1) == nil)
    #expect(data.int16(at: 2) == nil)
    #expect(data.int16(at: 3) == nil)
    #expect(data.int16(at: Int.max - 2) == nil)
  }

  @Test("accessors read offsets relative to a Data slice start")
  func accessorsReadRelativeToSliceStart() {
    let base = Data([0xAA, 0xBB, 0x12, 0x34, 0x56, 0xCC])
    let suffix = base[2..<5]
    let middle = base[1..<5]

    #expect(Array(suffix) == [0x12, 0x34, 0x56])
    #expect(suffix.uInt16(at: 0) == 0x1234)
    #expect(suffix.uInt16(at: 1) == 0x3456)
    #expect(suffix.uInt16(at: 2) == nil)

    #expect(Array(middle) == [0xBB, 0x12, 0x34, 0x56])
    #expect(middle.int16(at: 0) == Int16(bitPattern: 0xBB12))
    #expect(middle.int16(at: 1) == 0x1234)
    #expect(middle.int16(at: 2) == 0x3456)
    #expect(middle.int16(at: 3) == nil)
  }

  @Test("accessors are deterministic across repeated reads")
  func accessorsAreDeterministic() {
    let data = Data([0xDE, 0xAD, 0xBE, 0xEF])

    for _ in 0..<100 {
      #expect(data.uInt16(at: 0) == 0xDEAD)
      #expect(data.uInt16(at: 2) == 0xBEEF)
      #expect(data.int16(at: 0) == Int16(bitPattern: 0xDEAD))
      #expect(data.int16(at: 2) == Int16(bitPattern: 0xBEEF))
    }
  }

  @Test("uInt16 decodes every possible UInt16 bit pattern")
  func uInt16DecodesEveryPossibleBitPattern() {
    var firstMismatch: (value: UInt16, decoded: UInt16?)?

    for raw in UInt32(UInt16.min)...UInt32(UInt16.max) {
      let value = UInt16(raw)
      let data = Data([
        0xA5,
        UInt8(value >> 8),
        UInt8(value & 0x00FF),
        0x5A,
      ])

      let decoded = data.uInt16(at: 1)
      if decoded != value {
        firstMismatch = (value, decoded)
        break
      }
    }

    #expect(firstMismatch == nil)
  }

  @Test("int16 preserves every possible Int16 bit pattern")
  func int16PreservesEveryPossibleBitPattern() {
    var firstMismatch: (bits: UInt16, decoded: Int16?)?

    for raw in UInt32(UInt16.min)...UInt32(UInt16.max) {
      let bits = UInt16(raw)
      let data = Data([
        0xA5,
        UInt8(bits >> 8),
        UInt8(bits & 0x00FF),
        0x5A,
      ])

      let decoded = data.int16(at: 1)
      if decoded != Int16(bitPattern: bits) {
        firstMismatch = (bits, decoded)
        break
      }
    }

    #expect(firstMismatch == nil)
  }

  @Test("accessors match an independent oracle across generated byte streams")
  func accessorsMatchOracleAcrossGeneratedStreams() {
    let streams: [[UInt8]] = [
      (0..<257).map { UInt8(truncatingIfNeeded: $0) },
      (0..<257).map { UInt8(truncatingIfNeeded: $0 * 31 + 7) },
      (0..<257).map { UInt8(truncatingIfNeeded: $0 * $0 + 19) },
      (0..<257).map { UInt8(truncatingIfNeeded: ~$0) },
    ]

    for bytes in streams {
      let data = Data(bytes)

      for offset in 0..<(data.count - 1) {
        let expected = Self.uInt16Oracle(bytes[offset], bytes[offset + 1])

        #expect(data.uInt16(at: offset) == expected)
        #expect(data.int16(at: offset) == Int16(bitPattern: expected))
      }

      #expect(data.uInt16(at: data.count - 1) == nil)
      #expect(data.int16(at: data.count - 1) == nil)
    }
  }

  @Test("accessors match an independent oracle across lengths and boundary offsets")
  func accessorsMatchOracleAcrossLengthsAndBoundaryOffsets() {
    for count in 0...128 {
      let bytes = (0..<count).map { UInt8(truncatingIfNeeded: $0 * 13 + count) }
      let data = Data(bytes)
      let offsets = Array(-3...(count + 3)) + [Int.min, Int.max - 2]

      for offset in offsets {
        let expected = Self.expectedUInt16(bytes, at: offset)

        #expect(data.uInt16(at: offset) == expected)
        #expect(data.int16(at: offset) == expected.map(Int16.init(bitPattern:)))
      }
    }
  }

  @Test("accessors match an independent oracle across nonzero-start slices")
  func accessorsMatchOracleAcrossNonzeroStartSlices() {
    let baseBytes = (0..<64).map { UInt8(truncatingIfNeeded: $0 * 17 + 3) }
    let base = Data(baseBytes)

    for lowerBound in 1..<32 {
      for length in 0...16 {
        let upperBound = min(lowerBound + length, base.count)
        let slice = base[lowerBound..<upperBound]
        let sliceBytes = Array(slice)

        if sliceBytes.count < 2 {
          #expect(slice.uInt16(at: 0) == nil)
          #expect(slice.int16(at: 0) == nil)
          continue
        }

        for offset in 0..<(sliceBytes.count - 1) {
          let expected = Self.uInt16Oracle(sliceBytes[offset], sliceBytes[offset + 1])

          #expect(slice.uInt16(at: offset) == expected)
          #expect(slice.int16(at: offset) == Int16(bitPattern: expected))
        }

        #expect(slice.uInt16(at: sliceBytes.count - 1) == nil)
        #expect(slice.int16(at: sliceBytes.count - 1) == nil)
      }
    }
  }

  @Test("accessors read Data bridged from NSData")
  func accessorsReadBridgedNSDataStorage() {
    let bytes: [UInt8] = [0xCA, 0xFE, 0x80, 0x00, 0x7F, 0xFF]
    let nsData = NSData(bytes: bytes, length: bytes.count)
    let data = nsData as Data

    #expect(data.uInt16(at: 0) == 0xCAFE)
    #expect(data.int16(at: 0) == Int16(bitPattern: 0xCAFE))
    #expect(data.uInt16(at: 2) == 0x8000)
    #expect(data.int16(at: 2) == Int16.min)
    #expect(data.uInt16(at: 4) == 0x7FFF)
    #expect(data.int16(at: 4) == Int16.max)
    #expect(data.uInt16(at: 5) == nil)
  }

  @Test("accessors reflect mutations after Data copy-on-write")
  func accessorsReflectMutationsAfterCopyOnWrite() {
    var data = Data([0x12, 0x34, 0x56, 0x78])
    let original = data

    #expect(original.uInt16(at: 0) == 0x1234)
    #expect(data.uInt16(at: 0) == 0x1234)

    data[0] = 0xAB
    data[1] = 0xCD

    #expect(original.uInt16(at: 0) == 0x1234)
    #expect(data.uInt16(at: 0) == 0xABCD)
    #expect(data.int16(at: 0) == Int16(bitPattern: 0xABCD))
  }

  @Test("accessors handle offsets typed explicitly as Data.Index")
  func accessorsHandleDataIndexTypedOffsets() {
    let data = Data([0x01, 0x02, 0x03, 0x04])
    let first: Data.Index = 0
    let second: Data.Index = 1
    let lastValid: Data.Index = 2
    let firstInvalid: Data.Index = 3

    #expect(data.uInt16(at: first) == 0x0102)
    #expect(data.uInt16(at: second) == 0x0203)
    #expect(data.uInt16(at: lastValid) == 0x0304)
    #expect(data.uInt16(at: firstInvalid) == nil)

    #expect(data.int16(at: first) == 0x0102)
    #expect(data.int16(at: second) == 0x0203)
    #expect(data.int16(at: lastValid) == 0x0304)
    #expect(data.int16(at: firstInvalid) == nil)
  }

  private static func uInt16Oracle(_ first: UInt8, _ second: UInt8) -> UInt16 {
    UInt16(first) << 8 | UInt16(second)
  }

  private static func expectedUInt16(_ bytes: [UInt8], at offset: Int) -> UInt16? {
    guard offset >= 0, bytes.count >= offset + 2 else { return nil }

    return uInt16Oracle(bytes[offset], bytes[offset + 1])
  }
}
