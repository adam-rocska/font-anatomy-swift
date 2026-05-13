public func concretize(
  _ archetype: FontAnatomy_portedSlop,
  _ attribute: FontAnatomyMetric,
  _ value: Double
) -> FontAnatomy_portedSlop {
  let proportion = value / archetype[attribute]
  var result = FontAnatomy_portedSlop(
    unitsPerEm: archetype.unitsPerEm * proportion,
    ascender: archetype.ascender * proportion,
    descender: archetype.descender * proportion,
    xHeight: archetype.xHeight * proportion,
    capHeight: archetype.capHeight * proportion
  )
  result[attribute] = value
  return result
}
