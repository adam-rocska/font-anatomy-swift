# Font Anatomy for Swift

Swift implementation of `font-anatomy`, backed directly by the FreeType C library.

The first working slice includes:

- direct `FreeType` C API import through SwiftPM, not a Swift FreeType wrapper package
- `FT_Library` initialization and cleanup
- TTF/OTF face loading from memory or file URLs
- extraction of `unitsPerEm`, `ascender`, `descender`, `xHeight`, and `capHeight`
- relative, concretized, and equated metric transforms

## Font Loading Backends

The library target uses platform-native font loading on Apple platforms and a
SwiftPM `systemLibrary` backend on non-Apple platforms.

- Apple app targets use CoreText/CoreGraphics and do not require Homebrew
  FreeType or WOFF2 headers.
- Linux, Android, WASI, Windows, and OpenBSD targets use SwiftPM system
  libraries named `CFreeType` and `CWOFF2`. Toolchains must expose FreeType and
  WOFF2 through `pkg-config` as `freetype2` and `libwoff2dec`.
- The `font-anatomy` executable still uses FreeType directly for CLI metadata
  extraction on macOS/Linux.

Install examples:

```sh
brew install freetype woff2
```

```sh
apt-get install libfreetype6-dev libwoff-dev
```

WOFF2 support comes from CoreGraphics on Apple platforms and `libwoff2dec` on
non-Apple C-backend platforms.

## Usage

```swift
import FontAnatomy
import Foundation

let url = URL(fileURLWithPath: "LibertinusSans-Regular.ttf")
let anatomy = try fromFontFile(url)
let relative = anatomy.relative(to: \.unitsPerEm)
let twelvePointXHeight = anatomy.concretized(\.xHeight, as: 12)
```

## Portability

The Swift layer keeps Apple font APIs compile-gated. Non-Apple platforms need a
C font backend for the same target triple.

See [FreeTypePortability.md](./FreeTypePortability.md) for the current platform
position and the next step toward a fully vendored FreeType backend.
