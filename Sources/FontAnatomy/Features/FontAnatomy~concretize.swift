extension FontAnatomy where Value: FloatingPoint {
  public init(
    concretize anatomy: Self,
    attribute keyPath: KeyPath<Self, Value>,
    as value: Value
  ) {
    let proportion = value / anatomy[keyPath: keyPath]
    self.init(
      unitsPerEm: anatomy.unitsPerEm * proportion,
      ascender: anatomy.ascender * proportion,
      descender: anatomy.descender * proportion,
      xHeight: anatomy.xHeight * proportion,
      capHeight: anatomy.capHeight * proportion
    )
  }

  public func exactly(
    _ keyPath: KeyPath<Self, Value>,
    _ value: Value
  ) -> Self {
    Self(concretize: self, attribute: keyPath, as: value)
  }

  public static func concretizing(
    _ anatomy: Self,
    attribute keyPath: KeyPath<Self, Value>,
    as value: Value
  ) -> Self {
    Self(concretize: anatomy, attribute: keyPath, as: value)
  }
}
