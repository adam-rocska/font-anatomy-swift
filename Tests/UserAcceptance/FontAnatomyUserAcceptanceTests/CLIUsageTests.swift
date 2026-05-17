import FontAnatomy
import FontAnatomyTestSupport
import Foundation
import Testing

@Suite("CLI usage", .serialized, .timeLimit(.minutes(3)))
struct CLIUsageTests {
  @Test("The CLI fails when no input is provided")
  func noInputFails() throws {
    let result = try runCLI(input: Data())

    #expect(result.exitCode != 0)
    #expect(result.stderr.contains("No input received."))
  }

  @Test("The CLI emits JSON by default")
  func emitsDefaultJSON() throws {
    let input = try Data(contentsOf: poppinsRegularURL())
    let result = try runSuccessfulCLI(input: input)

    #expect(
      result.stdout
        == #"{"unitsPerEm":1000,"ascender":1050,"descender":-350,"xHeight":548,"capHeight":698}"#
    )
  }

  @Test("The CLI emits JSON when explicitly requested")
  func emitsExplicitJSON() throws {
    let input = try Data(contentsOf: poppinsRegularURL())
    let result = try runSuccessfulCLI(
      "--output-format=json",
      input: input
    )

    #expect(
      result.stdout
        == #"{"unitsPerEm":1000,"ascender":1050,"descender":-350,"xHeight":548,"capHeight":698}"#
    )
  }

  @Test("The CLI emits Markdown when requested")
  func emitsMarkdown() throws {
    let input = try Data(contentsOf: poppinsRegularURL())
    let result = try runSuccessfulCLI(
      "--output-format=md",
      "--heading-level=2",
      input: input
    )

    #expect(result.stdout.contains("## Poppins Regular"))
    #expect(result.stdout.contains("### Things to know"))
    #expect(result.stdout.contains("| Font Family      | Poppins"))
    #expect(result.stdout.contains("| Units Per Em | 1000"))
    #expect(result.stdout.contains("| X-Height     | 548"))
  }

  @Test("The CLI accepts the TypeScript heading short option")
  func acceptsHeadingShortOption() throws {
    let input = try Data(contentsOf: poppinsRegularURL())
    let result = try runSuccessfulCLI(
      "--output-format=md",
      "-h",
      "3",
      input: input
    )

    #expect(result.stdout.hasPrefix("### Poppins Regular"))
  }

  @Test("The CLI rejects invalid Markdown heading levels")
  func rejectsInvalidHeadingLevel() throws {
    let result = try runCLI(
      "--output-format=md",
      "--heading-level=0",
      input: Data()
    )

    #expect(result.exitCode != 0)
    #expect(result.stderr.contains("Invalid heading level."))
  }

  @Test("The CLI emits concretized JSON anatomy")
  func emitsConcretizedJSON() throws {
    let input = try Data(contentsOf: poppinsRegularURL())
    let result = try runSuccessfulCLI(
      "--concretize=xHeight",
      "--value=12",
      input: input
    )

    let anatomy = try JSONDecoder().decode(
      FontAnatomy<Double>.self,
      from: Data(result.stdout.utf8)
    )

    expectClose(anatomy.unitsPerEm, 21.8978102189781)
    expectClose(anatomy.ascender, 22.992700729927007)
    expectClose(anatomy.descender, -7.664233576642336)
    expectClose(anatomy.xHeight, 12)
    expectClose(anatomy.capHeight, 15.284671532846715)
  }

  @Test("The CLI emits concretized Markdown anatomy")
  func emitsConcretizedMarkdown() throws {
    let input = try Data(contentsOf: poppinsRegularURL())
    let result = try runSuccessfulCLI(
      "--output-format=md",
      "--concretize=xHeight",
      "--value=12",
      input: input
    )

    #expect(result.stdout.contains("| X-Height     | 12"))
    #expect(result.stdout.contains("| Cap Height   | 15.284671532846716"))
  }

  @Test("The CLI requires a finite value when concretizing")
  func requiresValueWhenConcretizing() throws {
    let result = try runCLI(
      "--concretize=xHeight",
      input: Data()
    )

    #expect(result.exitCode != 0)
    #expect(
      result.stderr.contains(
        "A finite --value is required when using --concretize."
      )
    )
  }

  @Test("The CLI rejects values without a concretize metric")
  func rejectsValueWithoutConcretizeMetric() throws {
    let result = try runCLI(
      "--value=12",
      input: Data()
    )

    #expect(result.exitCode != 0)
    #expect(result.stderr.contains("--value can only be used with --concretize."))
  }

  @Test("The CLI rejects invalid font bytes")
  func rejectsInvalidFontBytes() throws {
    let result = try runCLI(input: Data("not a font".utf8))

    #expect(result.exitCode != 0)
    #expect(result.stderr.contains("ftLoadFailure"))
  }
}

private func poppinsRegularURL() throws -> URL {
  try FontAnatomyFixture.url(
    for: FontAnatomyCorpusFixture.allCases.first {
      $0.resourceName == "Poppins-Regular"
    }!
  )
}

private func runSuccessfulCLI(
  _ arguments: String...,
  input: Data
) throws -> ProcessResult {
  let result = try runCLI(arguments, input: input)
  guard result.exitCode == 0 else {
    throw CLIProcessFailure(result: result)
  }
  return result
}

private func runCLI(
  _ arguments: String...,
  input: Data
) throws -> ProcessResult {
  try runCLI(arguments, input: input)
}

private func runCLI(
  _ arguments: [String] = [],
  input: Data
) throws -> ProcessResult {
  try cliRunner.run(arguments: arguments, input: input)
}

private func expectClose(
  _ actual: Double,
  _ expected: Double,
  tolerance: Double = 1e-12
) {
  #expect(abs(actual - expected) <= tolerance)
}

private struct CLIProcessFailure: Error, CustomStringConvertible {
  let result: ProcessResult

  var description: String {
    """
    Command failed with exit code \(result.exitCode):
    \(result.commandLine)

    stdout:
    \(result.stdout)

    stderr:
    \(result.stderr)
    """
  }
}

private let cliRunner = LazyCLIRunner()

private final class LazyCLIRunner: @unchecked Sendable {
  private let lock = NSLock()
  private var runner: CLIRunner?

  func run(arguments: [String], input: Data) throws -> ProcessResult {
    lock.lock()
    defer { lock.unlock() }

    if runner == nil {
      runner = try CLIRunner()
    }

    return try runner!.run(arguments: arguments, input: input)
  }
}

private final class CLIRunner {
  private let temporaryDirectory: TemporaryDirectory
  private let executable: URL

  init() throws {
    temporaryDirectory = try TemporaryDirectory(prefix: "FontAnatomyCLI")
    let swiftPM = try SwiftPM(
      workingDirectory: PackagePaths.root,
      stateDirectory: temporaryDirectory.appending("swiftpm-state")
    )

    _ = try swiftPM.run(["build", "--product", "font-anatomy"])
    let binPath = try swiftPM.run(["build", "--show-bin-path"])
      .stdout
      .trimmingCharacters(in: .whitespacesAndNewlines)

    executable = URL(fileURLWithPath: binPath)
      .appendingPathComponent("font-anatomy")
  }

  func run(arguments: [String], input: Data) throws -> ProcessResult {
    try ProcessRunner.run(
      executable,
      arguments: arguments,
      currentDirectory: PackagePaths.root,
      standardInput: input
    )
  }
}
