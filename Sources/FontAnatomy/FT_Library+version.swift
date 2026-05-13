import CFreeType
import VersionInfo

extension FT_Library {
  public lazy var version: SemanticVersion = {
    var major: FT_Int = 0
    var minor: FT_Int = 0
    var patch: FT_Int = 0

    FT_Library_Version(self, &major, &minor, &patch)

    return SemanticVersion(
      major: Int(major),
      minor: Int(minor),
      patch: Int(patch)
    )
  }
}
