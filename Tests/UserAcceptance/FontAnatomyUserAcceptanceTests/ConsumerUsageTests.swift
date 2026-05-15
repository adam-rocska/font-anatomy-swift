import FontAnatomyTestSupport
import Foundation
import Testing

@Suite("Consumer usage", .serialized, .timeLimit(.minutes(3)))
struct ConsumerUsageTests {
  @Test("A package can load font anatomy through the public URL initializer")
  func consumerLoadsFontFromURL() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("URLConsumer")
    let fixturePath = try FontAnatomyFixture.libertinusSansRegularURL().path
    let consumer = try FontAnatomyConsumerPackage.create(
      in: consumerDirectory,
      name: "URLConsumer",
      main: """
      import FontAnatomy
      import Foundation

      let url = URL(fileURLWithPath: \(String(reflecting: fixturePath)))
      let anatomy = try FontAnatomy<Int>(url)
      print("metrics=\\(anatomy.unitsPerEm),\\(anatomy.ascender),\\(anatomy.descender),\\(anatomy.xHeight),\\(anatomy.capHeight)")
      """
    )

    let result = try SwiftPM(
      workingDirectory: consumer.directory,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    ).run([
      "run",
      consumer.executableName,
    ])

    #expect(result.stdout.contains("metrics=1000,894,-246,460,658"))
  }

  @Test("A package can transform anatomy loaded from a real font")
  func consumerTransformsLoadedFont() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("TransformConsumer")
    let fixturePath = try FontAnatomyFixture.libertinusSansRegularURL().path
    let consumer = try FontAnatomyConsumerPackage.create(
      in: consumerDirectory,
      name: "TransformConsumer",
      main: """
      import FontAnatomy
      import Foundation

      let url = URL(fileURLWithPath: \(String(reflecting: fixturePath)))
      let anatomy = try FontAnatomy<Double>(url)
      let relative = anatomy.relative(to: \\.unitsPerEm)
      let concrete = anatomy.concretized(\\.xHeight, as: 12)
      let harmonized = concrete.equated(with: anatomy, by: \\.xHeight)

      print("relative=\\(relative.unitsPerEm),\\(relative.xHeight)")
      print("concrete=\\(concrete.xHeight)")
      print("harmonized=\\(harmonized.xHeight)")
      """
    )

    let result = try SwiftPM(
      workingDirectory: consumer.directory,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    ).run([
      "run",
      consumer.executableName,
    ])

    #expect(result.stdout.contains("relative=1.0,0.46"))
    #expect(result.stdout.contains("concrete=12.0"))
    #expect(result.stdout.contains("harmonized=12.0"))
  }

  @Test("A package can construct a sample prototype anatomy and make it concrete")
  func consumerConstructsSamplePrototype() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("PrototypeConsumer")
    let consumer = try FontAnatomyConsumerPackage.create(
      in: consumerDirectory,
      name: "PrototypeConsumer",
      main: """
      import FontAnatomy

      let prototype = FontAnatomy<Double>(
        unitsPerEm: 1000,
        ascender: 1050,
        descender: -350,
        xHeight: 558,
        capHeight: 705
      )
      let concrete = prototype.concretized(\\.xHeight, as: 12)
      print("xHeight=\\(concrete.xHeight)")
      """
    )

    let result = try SwiftPM(
      workingDirectory: consumer.directory,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    ).run([
      "run",
      consumer.executableName,
    ])

    #expect(result.stdout.contains("xHeight=12.0"))
  }

  @Test("A package can encode, decode, hash, and compare loaded anatomy")
  func consumerUsesCodableAndHashableConformances() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("CodableConsumer")
    let fixturePath = try FontAnatomyFixture.libertinusSansRegularURL().path
    let consumer = try FontAnatomyConsumerPackage.create(
      in: consumerDirectory,
      name: "CodableConsumer",
      main: """
      import FontAnatomy
      import Foundation

      let url = URL(fileURLWithPath: \(String(reflecting: fixturePath)))
      let anatomy = try FontAnatomy<Int>(url)
      let encoded = try JSONEncoder().encode(anatomy)
      let decoded = try JSONDecoder().decode(FontAnatomy<Int>.self, from: encoded)
      let uniqueValues: Set<FontAnatomy<Int>> = [anatomy, decoded]

      print("roundTrip=\\(decoded == anatomy)")
      print("unique=\\(uniqueValues.count)")
      """
    )

    let result = try SwiftPM(
      workingDirectory: consumer.directory,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    ).run([
      "run",
      consumer.executableName,
    ])

    #expect(result.stdout.contains("roundTrip=true"))
    #expect(result.stdout.contains("unique=1"))
  }

  @Test("A package can use loaded anatomy across Swift concurrency boundaries")
  func consumerUsesAnatomyAcrossConcurrencyBoundaries() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("ConcurrencyConsumer")
    let fixturePath = try FontAnatomyFixture.libertinusSansRegularURL().path
    let consumer = try FontAnatomyConsumerPackage.create(
      in: consumerDirectory,
      name: "ConcurrencyConsumer",
      main: """
      import FontAnatomy
      import Foundation

      @main
      struct Runner {
        static func main() async throws {
          let url = URL(fileURLWithPath: \(String(reflecting: fixturePath)))
          let anatomy = try FontAnatomy<Int>(url)
          requireSendable(anatomy)

          let loaded = try await Task.detached {
            try FontAnatomy<Int>(url)
          }.value

          print("sendable=ok")
          print("loaded=\\(loaded.xHeight)")
        }

        static func requireSendable<T: Sendable>(_ value: T) {}
      }
      """
    )

    let result = try SwiftPM(
      workingDirectory: consumer.directory,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    ).run([
      "run",
      consumer.executableName,
    ])

    #expect(result.stdout.contains("sendable=ok"))
    #expect(result.stdout.contains("loaded=460"))
  }

  @Test("A consumer package depending on FontAnatomy builds in release mode")
  func consumerBuildsInReleaseMode() throws {
    let temporaryDirectory = try TemporaryDirectory()
    let consumerDirectory = try temporaryDirectory.createDirectory("ReleaseConsumer")
    let fixturePath = try FontAnatomyFixture.libertinusSansRegularURL().path
    let consumer = try FontAnatomyConsumerPackage.create(
      in: consumerDirectory,
      name: "ReleaseConsumer",
      main: """
      import FontAnatomy
      import Foundation

      let url = URL(fileURLWithPath: \(String(reflecting: fixturePath)))
      let anatomy = try FontAnatomy<Double>(url)
      print(anatomy.relative(to: \\.unitsPerEm).capHeight)
      """
    )

    _ = try SwiftPM(
      workingDirectory: consumer.directory,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    ).run([
      "build",
      "-c",
      "release",
    ])
  }
}
