extension FontAnatomy where Value: FloatingPoint {
  public init(
    equate base: Self,
    with target: Self,
    by keyPath: KeyPath<Self, Value>
  ) {
    self.init(
      concretize: target,
      attribute: keyPath,
      as: base[keyPath: keyPath]
    )
  }

  public func equate(
    with target: Self,
    by keyPath: KeyPath<Self, Value>
  ) -> Self {
    Self(equate: self, with: target, by: keyPath)
  }

  public static func equating(
    _ base: Self,
    with target: Self,
    by keyPath: KeyPath<Self, Value>
  ) -> Self {
    Self(equate: base, with: target, by: keyPath)
  }
}
