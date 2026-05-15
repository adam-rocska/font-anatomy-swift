extension FontAnatomy where Value: FloatingPoint {
  public init(
    equating base: Self,
    with target: Self,
    by keyPath: KeyPath<Self, Value>
  ) {
    self.init(
      concretizing: target,
      by: keyPath,
      as: base[keyPath: keyPath]
    )
  }

  public func equated(
    with target: Self,
    by keyPath: KeyPath<Self, Value>
  ) -> Self {
    Self(equating: self, with: target, by: keyPath)
  }

  public static func equating(
    _ base: Self,
    with target: Self,
    by keyPath: KeyPath<Self, Value>
  ) -> Self {
    Self(equating: base, with: target, by: keyPath)
  }
}
