# FreeType Portability

This repository uses two font-loading backends:

- Apple library builds use CoreText/CoreGraphics for in-memory TTF, OTF, and
  WOFF2 loading.
- Linux, Android, WASI, Windows, and OpenBSD library builds use FreeType and
  WOFF2 through SwiftPM `systemLibrary` targets.

The split keeps Xcode app targets independent from Homebrew headers while still
leaving a stable C boundary for platforms that need FreeType.

## Current Backend

- Apple `FontAnatomy` file/data/byte initializers create a `CGFont`, wrap it in
  `CTFont`, and read the `head`, `hhea`, and `OS/2` tables through CoreText.
- Non-Apple `CFreeType` imports `<ft2build.h>`, `FT_FREETYPE_H`, and
  `FT_TRUETYPE_TABLES_H`.
- Non-Apple `FontAnatomy` calls `FT_Init_FreeType`, `FT_New_Memory_Face`,
  `FT_Get_Sfnt_Table`, `FT_Done_Face`, and `FT_Done_FreeType`.
- Swift code uses in-memory font bytes, so the core path is not tied to POSIX
  file APIs.

## Platform Requirements

The package can build for a platform when that platform's Swift toolchain can
also see a font backend for the same target triple.

- Apple platforms: no external FreeType or WOFF2 dependency is required for the
  library product.
- Linux: install `libfreetype6-dev` or the distribution equivalent that exposes
  `freetype2.pc`, and install WOFF2 development files that expose
  `libwoff2dec.pc`.
- Android, WASI/WebAssembly, Windows, and OpenBSD: provide FreeType and WOFF2
  builds for the target triple and make their `pkg-config` metadata visible to
  SwiftPM.

## WOFF2

Apple builds rely on CoreGraphics' WOFF2 support. Non-Apple C-backend builds use
`libwoff2dec` before passing decompressed SFNT bytes to FreeType.

A backend that must support TTF, OTF, and WOFF2 on every non-Apple target should
vendor FreeType, WOFF2, and Brotli source, then build them for each Swift target
triple. That vendored backend is the next portability step.
