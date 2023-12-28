/// A dimension of measurement. These may be combined to form composite dimensions.
/// This type can also be extended for custom dimensions that cannot be
/// neatly reduced into any of the 7 base SI units.
public struct Dimension: Hashable, Equatable, Sendable {
    let name: String
    let symbol: String

    init(name: String = #function, symbol: String) {
        self.name = name
        self.symbol = symbol
    }

    /// The SI base unit for an amount of a substance.
    public static var mole: Self { .init(symbol: "mol") }

    /// The SI base unit for electric current.
    public static var ampere: Self { .init(symbol: "A") }

    /// The SI base unit for length.
    public static var meter: Self { .init(symbol: "m") }

    /// The SI base unit for mass.
    public static var kilogram: Self { .init(symbol: "kg") }

    /// The SI base unit for temperature.
    public static var kelvin: Self { .init(symbol: "K") }

    /// The SI base unit for time.
    public static var second: Self { .init(symbol: "s") }

    /// The SI base unit for luminous intensity.
    public static var candela: Self { .init(symbol: "cd") }


    /// The extended SI base unit for angle.
    public static var radian: Self { .init(symbol: "rad") }


    /// The extended SI base unit for data.
    public static var bit: Self { .init(symbol: "bit") }
}

extension Dimension: CustomStringConvertible {
    public var description: String { symbol }
}
