# Font Anatomy for Swift

Swift implementation of `font-anatomy`, backed directly by the FreeType C library.

The first working slice includes:

- direct `FreeType` C API import through SwiftPM, not a Swift FreeType wrapper package
- `FT_Library` initialization and cleanup
- TTF/OTF face loading from memory or file URLs
- extraction of `unitsPerEm`, `ascender`, `descender`, `xHeight`, and `capHeight`
- `relativize`, `concretize`, and `equate` metric transforms

## FreeType Dependency

This package currently uses a SwiftPM `systemLibrary` target named `CFreeType`.
On development machines it expects FreeType to be available through `pkg-config`
as `freetype2`.

Install examples:

```sh
brew install freetype
```

```sh
apt-get install libfreetype6-dev
```

WOFF2 support depends on the linked FreeType library being compiled with Brotli
support. The Swift package does not paper over that: a FreeType build without
Brotli will load TTF/OTF fonts but reject WOFF2 files.

## Usage

```swift
import FontAnatomy
import Foundation

let url = URL(fileURLWithPath: "LibertinusSans-Regular.ttf")
let anatomy = try fromFontFile(url)
let relative = relativize(.unitsPerEm, anatomy)
let twelvePointXHeight = concretize(anatomy, .xHeight, 12)
```

## Portability

The Swift layer has no Darwin-only font APIs. The portability contract is the C
FreeType ABI: every target platform must provide headers and a library for the
same target triple.

See [FreeTypePortability.md](./FreeTypePortability.md) for the current platform
position and the next step toward a fully vendored FreeType backend.
