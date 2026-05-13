public func equate(
  _ base: FontAnatomy_portedSlop,
  _ anatomy: FontAnatomy_portedSlop,
  _ field: FontAnatomyMetric
) -> FontAnatomy_portedSlop {
  concretize(anatomy, field, base[field])
}
