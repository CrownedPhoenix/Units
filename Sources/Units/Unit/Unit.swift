import func Foundation.pow

/// A unit type that is composed of any combination of base dimensions and a coefficient
public struct Unit: Hashable, Equatable, Sendable {
    public let dimension: [Dimension: Int]
    public let coefficient: Double
    public let constant: Double
    var composite: Bool

    init(dimension: [Dimension: Int], coefficient: Double = 1, constant: Double = 0, composite: Bool = false) {
        self.dimension = dimension
        self.coefficient = coefficient
        self.constant = constant
        self.composite = composite
    }

    public static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.dimension == rhs.dimension
        && lhs.coefficient == rhs.coefficient
        && lhs.constant == rhs.constant
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(dimension)
        hasher.combine(coefficient)
        hasher.combine(constant)
    }
}

// MARK: - Arithmatic
public extension Unit {

    /// Multiply the units.
    /// - Parameters:
    ///   - lhs: The left-hand-side unit
    ///   - rhs: The right-hand-side unit
    /// - Returns: A unit modeling the product of the left-hand-side and right-hand-side units
    static func * (coefficient: Double, unit: Self) -> Self {
        Self(
            dimension: unit.dimension,
            coefficient: unit.coefficient * coefficient,
            constant: unit.constant
        )
    }

    /// Multiply the units.
    /// - Parameters:
    ///   - lhs: The left-hand-side unit
    ///   - rhs: The right-hand-side unit
    /// - Returns: A unit modeling the product of the left-hand-side and right-hand-side units
    static func * (lhs: Self, rhs: Self) -> Self {
        var newDimension = lhs.dimension
        newDimension.merge(rhs.dimension) { lhsUnitExp, rhsUnitExp in
            lhsUnitExp + rhsUnitExp
        }
        newDimension = newDimension.filter { _, value in
            value != 0
        }
        return Self(
            dimension: newDimension,
            coefficient: lhs.coefficient * rhs.coefficient,
            constant: lhs.constant + rhs.constant,
            composite: true
        )
    }

    /// Divide the units.
    /// - Parameters:
    ///   - lhs: The left-hand-side unit
    ///   - rhs: The right-hand-side unit
    /// - Returns: A unit modeling the left-hand-side unit divided by the right-hand-side unit.
    static func / (lhs: Self, rhs: Self) -> Self {
        let invertedRhsDimension = rhs.dimension.mapValues { rhsUnitExp in
            -1 * rhsUnitExp
        }

        var newDimension = lhs.dimension
        newDimension.merge(invertedRhsDimension) { lhsUnitExp, negRhsUnitExp in
            lhsUnitExp + negRhsUnitExp
        }
        newDimension = newDimension.filter { _, value in
            value != 0
        }
        return Self(
            dimension: newDimension,
            coefficient: lhs.coefficient / rhs.coefficient,
            constant: lhs.constant + rhs.constant,
            composite: true
        )
    }

    /// Exponentiate the unit. This is equivalent to multiple `*` operations.
    /// - Parameter raiseTo: The exponent to raise the unit to
    /// - Returns: A new unit modeling the original raised to the provided power
    func pow(_ exponent: Int) -> Self {
        Self(
            dimension: dimension.reduce(
                into: [Dimension: Int](),
                { $0[$1.key] = $1.value * exponent }
            ),
            coefficient: Foundation.pow(coefficient, Double(exponent)),
            constant: constant,
            composite: true
        )
    }
}


// MARK: Conversions
extension Unit {
    /// Tests that two units are of the same dimension
    /// - Parameter to: The unit to compare this one to
    /// - Returns: A bool indicating whether this unit and the input unit are of the same dimension
    public func isDimensionallyEquivalent(to: Self) -> Bool {
        return dimension == to.dimension
    }

    /// Convert a provided amount of this unit to base dimensional units. This unit's conversion definition is used.
    ///
    /// For example, `Unit.kilometer.toBaseUnit(5)` will return `5000`, since `5km = 5000m`
    ///
    /// - Parameter number: The amount of this unit to convert to the base units.
    /// - Returns: The equivalent amount in terms of the dimensional base units.
    func toBaseUnit(_ number: Double) throws -> Double {
        if composite && constant != 0 {
            throw UnitError.invalidCompositeUnit(message: "Composite, non-linear unit cannot be converted.")
        }
        return number * coefficient + constant
    }

    /// Convert a provided amount of base dimensional units to this unit. This unit's conversion definition is used.
    ///
    /// For example, `Unit.kilometer.fromBaseUnit(5)` will return `0.005`, since `5m = 0.005km`
    ///
    /// - Parameter number: The amount of base units to convert to this unit.
    /// - Returns: The equivalent amount in terms of this unit.
    func fromBaseUnit(_ number: Double) throws -> Double {
        if composite && constant != 0 {
            throw UnitError.invalidCompositeUnit(message: "Composite, non-linear unit cannot be converted.")
        }
        return (number - constant) / coefficient
    }
}

// MARK: Custom Units
extension Unit {
    public static func define(dimension name: String, symbol: String? = nil) -> Self {
        Unit(dimension: [Dimension(name: name, symbol: name): 1])
    }
}


// MARK: Default Serialization
extension Unit: LosslessStringConvertible {
    public var symbol: String { description }

    public var description: String {
        let positiveExponents = dimension.compactMap({ $0.value > 0 ? (dim: $0.key, exp: $0.value) : nil })
        let negativeExponents = dimension.compactMap({ $0.value < 0 ? (dim: $0.key, exp: -$0.value) : nil })
        if positiveExponents.isEmpty, negativeExponents.isEmpty { return "" }

        let numerator = positiveExponents.isEmpty ? "\(coefficient != 1 ? "" : "1")" : positiveExponents.map({ "\($0.dim)\($0.exp > 1 ? $0.exp.base10Superscript : "")" }).joined(separator: "·")
        let denominator = negativeExponents.isEmpty ? "" : negativeExponents.map({ "\($0.dim)\($0.exp > 1 ? $0.exp.base10Superscript : "")" }).joined(separator: "·")

        return "\(coefficient != 1 ? "(\(coefficient)\(positiveExponents.isEmpty ? "" : " ")" : "")\(numerator)\(negativeExponents.isEmpty ? "" : "/")\(denominator)\(coefficient != 1 ? ")" : "")"
    }

    /// Initialize a unit from the provided string. This checks the input against the symbols stored
    /// in the registry. If no match is found, nil is returned.
    public init?(_ description: String) {
        self = .unitless
    }
}

extension Int {
    var base10Superscript: String {
        String(String(self).map({ intSuperscripts[$0] ?? $0 }))
    }

}

fileprivate let intSuperscripts: [Character: Character] = [
    "1": "\u{00B9}",
    "2": "\u{00B2}",
    "3": "\u{00B3}",
    "4": "\u{2074}",
    "5": "\u{2075}",
    "6": "\u{2076}",
    "7": "\u{2077}",
    "8": "\u{2078}",
    "9": "\u{2079}"]
