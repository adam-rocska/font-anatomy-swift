# Test Font Fixture

The fixtures are copied from the TypeScript implementation's test corpus to
keep Swift package tests self-contained.

`LibertinusSans-Regular.ttf` metadata reports:

- Family: Libertinus Sans
- Style: Regular
- Version: 7.051;RELEASE
- Designer: Philipp H. Poll, Khaled Hosny
- Manufacturer: Caleb Maclennan
- Source: https://github.com/alerque/libertinus
- License: SIL Open Font License, Version 1.1
- License URL: https://openfontlicense.org

Additional fixtures:

- `NotoSerif-VariableFont_wdth,wght.ttf` covers variable TTF loading.
- `AtkinsonHyperlegibleNextVF-Variable.woff2` covers WOFF2 when the linked
  FreeType build has Brotli support.
