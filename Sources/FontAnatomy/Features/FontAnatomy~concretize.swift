extension FontAnatomy where Value: FloatingPoint {
  public init(
    concretizing prototype: Self,
    by keyPath: KeyPath<Self, Value>,
    as value: Value
  ) {
    let proportion = value / prototype[keyPath: keyPath]
    self.init(
      unitsPerEm: prototype.unitsPerEm * proportion,
      ascender: prototype.ascender * proportion,
      descender: prototype.descender * proportion,
      xHeight: prototype.xHeight * proportion,
      capHeight: prototype.capHeight * proportion
    )
  }

  public func concretized(
    _ keyPath: KeyPath<Self, Value>,
    as value: Value
  ) -> Self {
    Self(concretizing: self, by: keyPath, as: value)
  }

  public static func concretizing(
    _ prototype: Self,
    by keyPath: KeyPath<Self, Value>,
    as value: Value
  ) -> Self {
    Self(concretizing: prototype, by: keyPath, as: value)
  }
}
