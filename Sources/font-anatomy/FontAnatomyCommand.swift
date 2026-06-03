import ArgumentParser
import CFreeType
import FontAnatomy
import Foundation

@main
struct FontAnatomyCommand: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "font-anatomy",
    abstract: "Extract font anatomy metrics from font bytes.",
    version: versions.head.name,
    helpNames: .long
  )

  @Option(
    name: [
      .customLong("output-format"),
      .customLong("outputFormat"),
      .customShort("o"),
    ]
  )
  var outputFormat: OutputFormat = .json

  @Option(
    name: [
      .customLong("heading-level"),
      .customLong("headingLevel"),
      .customShort("h"),
    ]
  )
  var headingLevel: Int = 1

  @Option
  var concretize: Metric?

  @Option
  var value: Double?

  mutating func validate() throws {
    if concretize != nil {
      guard let value, value.isFinite else {
        throw ValidationError(
          "A finite --value is required when using --concretize."
        )
      }
    } else if value != nil {
      throw ValidationError("--value can only be used with --concretize.")
    }

    if outputFormat == .md && !(1...5).contains(headingLevel) {
      throw ValidationError("Invalid heading level.")
    }
  }

  mutating func run() throws {
    let input = FileHandle.standardInput.readDataToEndOfFile()
    guard !input.isEmpty else {
      throw ValidationError("No input received.")
    }

    let anatomy = try FontAnatomy<Double>(input)
    let transformed =
      concretize.map {
        anatomy.concretized($0.keyPath, as: value!)
      } ?? anatomy

    switch outputFormat {
    case .json:
      writeJSON(transformed)
    case .md:
      writeMarkdown(transformed, metadata: FontMetadata(data: input))
    }
  }

  private func writeJSON(_ anatomy: FontAnatomy<Double>) {
    let json =
      "{"
      + "\"unitsPerEm\":\(formatJSON(anatomy.unitsPerEm)),"
      + "\"ascender\":\(formatJSON(anatomy.ascender)),"
      + "\"descender\":\(formatJSON(anatomy.descender)),"
      + "\"xHeight\":\(formatJSON(anatomy.xHeight)),"
      + "\"capHeight\":\(formatJSON(anatomy.capHeight))"
      + "}"
    FileHandle.standardOutput.write(Data(json.utf8))
  }

  private func writeMarkdown(
    _ anatomy: FontAnatomy<Double>,
    metadata: FontMetadata
  ) {
    let relative = anatomy.relative(to: \.unitsPerEm)
    let markdown = [
      heading(headingLevel, metadata.fullName),
      "",
      "Extracted using `font-anatomy`, a CLI utility of",
      "[`@adam-rocska/font-anatomy`](https://github.com/adam-rocska/font-anatomy)",
      "",
      heading(headingLevel + 1, "Things to know"),
      "",
      markdownTable(
        ["Attribute", "Value"],
        ["Copyright", metadata.copyright],
        ["Description", metadata.description],
        ["Designer", metadata.designer],
        ["Designer URL", metadata.designerURL],
        ["Font Family", metadata.fontFamily],
        ["Font Subfamily", metadata.fontSubfamily],
        ["Full Name", metadata.fullName],
        ["License", metadata.license],
        ["License URL", metadata.licenseURL],
        ["Manufacturer", metadata.manufacturer],
        ["Manufacturer URL", metadata.manufacturerURL],
        ["postScript Name", metadata.postScriptName],
        ["Trademark", metadata.trademark],
        ["Version", metadata.version]
      ),
      "",
      heading(headingLevel + 1, "Anatomy"),
      "",
      markdownTable(
        ["Trait", "Absolute Value", "Relative Value"],
        [
          "Units Per Em", format(anatomy.unitsPerEm),
          format(relative.unitsPerEm),
        ],
        ["Ascender", format(anatomy.ascender), format(relative.ascender)],
        ["Descender", format(anatomy.descender), format(relative.descender)],
        ["X-Height", format(anatomy.xHeight), format(relative.xHeight)],
        ["Cap Height", format(anatomy.capHeight), format(relative.capHeight)]
      ),
      "",
    ].joined(separator: "\n")

    FileHandle.standardOutput.write(Data(markdown.utf8))
  }
}

enum OutputFormat: String, ExpressibleByArgument {
  case json
  case md
}

enum Metric: String, ExpressibleByArgument {
  case unitsPerEm
  case ascender
  case descender
  case xHeight
  case capHeight

  var keyPath: KeyPath<FontAnatomy<Double>, Double> {
    switch self {
    case .unitsPerEm: \.unitsPerEm
    case .ascender: \.ascender
    case .descender: \.descender
    case .xHeight: \.xHeight
    case .capHeight: \.capHeight
    }
  }
}

private struct FontMetadata {
  var copyright = ""
  var description = ""
  var designer = ""
  var designerURL = ""
  var fontFamily = ""
  var fontSubfamily = ""
  var fullName = ""
  var license = ""
  var licenseURL = ""
  var manufacturer = ""
  var manufacturerURL = ""
  var postScriptName = ""
  var trademark = ""
  var version = ""

  init(data: Data) {
    let names = SfntNames(data: data).localizedNames
    copyright = names[0] ?? ""
    description = names[10] ?? ""
    designer = names[9] ?? ""
    designerURL = names[12] ?? ""
    fontFamily = names[1] ?? ""
    fontSubfamily = names[2] ?? ""
    fullName = names[4] ?? ""
    license = names[13] ?? ""
    licenseURL = names[14] ?? ""
    manufacturer = names[8] ?? ""
    manufacturerURL = names[11] ?? ""
    postScriptName = names[6] ?? ""
    trademark = names[7] ?? ""
    version = names[5] ?? ""
  }
}

private struct SfntNames {
  let localizedNames: [UInt16: String]

  init(data: Data) {
    self.localizedNames = data.withUnsafeBytes { bytes in
      guard let baseAddress = bytes.baseAddress else { return [:] }

      var library: FT_Library?
      var error = FT_Init_FreeType(&library)
      guard error == 0, let library else { return [:] }
      defer { FT_Done_FreeType(library) }

      var face: FT_Face?
      error = FT_New_Memory_Face(
        library,
        baseAddress.assumingMemoryBound(to: FT_Byte.self),
        FT_Long(bytes.count),
        0,
        &face
      )
      guard error == 0, let face else { return [:] }
      defer { FT_Done_Face(face) }

      return Self.loadNames(from: face)
    }
  }

  private static func loadNames(from face: FT_Face) -> [UInt16: String] {
    var candidates: [UInt16: [NameCandidate]] = [:]
    let count = FT_Get_Sfnt_Name_Count(face)

    for index in 0..<count {
      var sfntName = FT_SfntName()
      guard FT_Get_Sfnt_Name(face, index, &sfntName) == 0 else { continue }
      guard let value = String(sfntName: sfntName) else { continue }

      candidates[UInt16(sfntName.name_id), default: []].append(
        NameCandidate(
          platformID: UInt16(sfntName.platform_id),
          languageID: UInt16(sfntName.language_id),
          value: value
        )
      )
    }

    return candidates.mapValues { candidates in
      candidates.min { $0.priority < $1.priority }?.value ?? ""
    }
  }
}

private struct NameCandidate {
  let platformID: UInt16
  let languageID: UInt16
  let value: String

  var priority: Int {
    if platformID == 3 && isWindowsEnglish { return 0 }
    if platformID == 0 { return 1 }
    if platformID == 1 && languageID == 0 { return 2 }
    if platformID == 3 { return 3 }
    if platformID == 1 { return 4 }
    return 5
  }

  private var isWindowsEnglish: Bool {
    (languageID & 0x03FF) == 0x0009
  }
}

extension String {
  fileprivate init?(sfntName: FT_SfntName) {
    guard let string = sfntName.string else { return nil }

    let bytes = Array(
      UnsafeBufferPointer(
        start: string,
        count: Int(sfntName.string_len)
      )
    )

    if sfntName.platform_id == 0 || sfntName.platform_id == 3 {
      guard bytes.count.isMultiple(of: 2) else { return nil }
      let codeUnits = stride(from: 0, to: bytes.count, by: 2).map { offset in
        UInt16(bytes[offset]) << 8 | UInt16(bytes[offset + 1])
      }
      self = String(decoding: codeUnits, as: UTF16.self)
      return
    }

    if let utf8 = String(bytes: bytes, encoding: .utf8) {
      self = utf8
      return
    }

    self = String(decoding: bytes, as: UTF8.self)
  }
}

private func heading(_ level: Int, _ text: String) -> String {
  "\(String(repeating: "#", count: level)) \(text)"
}

private func markdownTable(_ rows: [String]...) -> String {
  guard let columnCount = rows.first?.count else { return "" }
  let widths = (0..<columnCount).map { column in
    rows.map { $0[column].count }.max() ?? 0
  }

  let separator = widths.map { String(repeating: "-", count: $0) }
  return ([rows[0], separator] + rows.dropFirst()).map { row in
    "| "
      + row.enumerated().map { column, cell in
        cell.padding(toLength: widths[column], withPad: " ", startingAt: 0)
      }.joined(separator: " | ") + " |"
  }.joined(separator: "\n")
}

private func format(_ value: Double) -> String {
  if value.isFinite && value.rounded() == value
    && value >= Double(Int.min)
    && value <= Double(Int.max)
  {
    return String(Int(value))
  }
  return String(describing: value)
}

private func formatJSON(_ value: Double) -> String {
  guard value.isFinite else { return "null" }
  return format(value)
}
