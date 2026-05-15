extension FontAnatomy where Value: FloatingPoint {
  public init(
    relativize anatomy: Self,
    basedOn keyPath: KeyPath<Self, Value>
  ) {
    let basis = anatomy[keyPath: keyPath]
    self.init(
      unitsPerEm: anatomy.unitsPerEm / basis,
      ascender: anatomy.ascender / basis,
      descender: anatomy.descender / basis,
      xHeight: anatomy.xHeight / basis,
      capHeight: anatomy.capHeight / basis
    )
  }

  public func relative(
    to keyPath: KeyPath<Self, Value>
  ) -> Self {
    Self(relativize: self, basedOn: keyPath)
  }

  public static func relativizing(
    _ anatomy: Self,
    basedOn keyPath: KeyPath<Self, Value>
  ) -> Self {
    Self(relativize: anatomy, basedOn: keyPath)
  }
}
