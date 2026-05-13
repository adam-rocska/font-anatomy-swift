public func relativize(
  _ basedOn: FontAnatomyMetric, _ anatomy: FontAnatomy_portedSlop
) -> FontAnatomy_portedSlop {
  let basis = anatomy[basedOn]

  return FontAnatomy_portedSlop(
    unitsPerEm: anatomy.unitsPerEm / basis,
    ascender: anatomy.ascender / basis,
    descender: anatomy.descender / basis,
    xHeight: anatomy.xHeight / basis,
    capHeight: anatomy.capHeight / basis
  )
}
