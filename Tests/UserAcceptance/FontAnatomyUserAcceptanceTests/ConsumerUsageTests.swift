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
}
