# FreeType Portability

This repository uses the FreeType C library directly through a SwiftPM
`systemLibrary` target. That gives the Swift code a stable C boundary without
depending on a third-party Swift wrapper.

## Current Backend

- `CFreeType` imports `<ft2build.h>`, `FT_FREETYPE_H`, and
  `FT_TRUETYPE_TABLES_H`.
- `FontAnatomy` calls `FT_Init_FreeType`, `FT_New_Memory_Face`,
  `FT_Get_Sfnt_Table`, `FT_Done_Face`, and `FT_Done_FreeType`.
- Swift code uses in-memory font bytes, so the core path is not tied to POSIX
  file APIs.

## Platform Requirements

The package can build for a platform when that platform's Swift toolchain can
also see a FreeType build for the same target triple.

- Apple platforms: provide FreeType headers and a static library/XCFramework
  built for macOS, iOS, tvOS, watchOS, visionOS, and simulator variants.
- Linux: install `libfreetype6-dev` or the distribution equivalent that exposes
  `freetype2.pc`.
- Android: provide a cross-compiled FreeType for the Android NDK target and make
  its `pkg-config` metadata visible during the SwiftPM build.
- WASI/WebAssembly: provide a WASI-compatible FreeType build and make its
  headers and archive visible to the SwiftPM target.

## WOFF2

WOFF2 is not automatic. FreeType needs Brotli support enabled at FreeType build
time. A backend that must support TTF, OTF, and WOFF2 everywhere should vendor
FreeType and Brotli source, then build both for each Swift target triple.

That vendored backend is the next portability step. The current system-library
backend is enough to prove the direct C API boundary and to keep the Swift
library code independent from platform font frameworks.
