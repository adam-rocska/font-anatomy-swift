extension FontAnatomy where Value: FloatingPoint {
  public init(
    concretizing prototype: Self,
    by keyPath: KeyPath<Self, Value>,
    as value: Value
  ) {
    let proportion = value / prototype[keyPath: keyPath]
    let resolve = { (metric: KeyPath<Self, Value>) in
      metric == keyPath
        ? value
        : prototype[keyPath: metric] * proportion
    }
    self.init(
      unitsPerEm: resolve(\.unitsPerEm),
      ascender: resolve(\.ascender),
      descender: resolve(\.descender),
      xHeight: resolve(\.xHeight),
      capHeight: resolve(\.capHeight)
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
