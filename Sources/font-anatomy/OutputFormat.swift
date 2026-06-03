import ArgumentParser

enum OutputFormat: String, ExpressibleByArgument {
  case json
  case md
}
