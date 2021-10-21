import Foundation

public struct Unit {
    
    private let type: UnitType
    
    /// Define a new Unit
    /// - parameter symbol: The string symbol of the unit. This should be globally unique
    /// - parameter dimension: The unit dimensionality as a map of base quantities and their respective exponents.
    /// - parameter coefficient: The value to multiply a base unit of this dimension when converting it to this unit. For base units, this is 1.
    /// - parameter constant: The value to add to a base unit when converting it to this unit. This is added after the coefficient is multiplied according to order-of-operations.
    public init(symbol: String, dimension: [Quantity: Int], coefficient: Double = 1, constant: Double = 0) {
        self.type = .defined(DefinedUnit(dimension: dimension, symbol: symbol, coefficient: coefficient, constant: constant))
    }
    
    /// Create a new composite Unit
    /// - parameter composedOf: A list of units and exponents that define this composite unit. The units used as keys must be defined units.
    private init(composedOf: [DefinedUnit: Int]) {
        self.type = .composite(composedOf)
    }
    
    /// Return the dimension of the unit in terms of base quanties
    public var dimension: [Quantity: Int] {
        switch type {
        case .defined(let definition):
            return definition.dimension
        case .composite(let subUnits):
            var dimensions: [Quantity: Int] = [:]
            for (subUnit, exp) in subUnits {
                // multiply subDimensions by unit exponent
                let subDimensions = subUnit.dimension.mapValues { value in
                    exp * value
                }
                // Append or sum values into computed dimension
                // TODO: Abstract & unify this process across methods
                for (subDimension, subDimExp) in subDimensions {
                    if let existingExp = dimensions[subDimension] {
                        let newExp = existingExp + subDimExp
                        if newExp == 0 {
                            dimensions.removeValue(forKey: subDimension)
                        } else {
                            dimensions[subDimension] = newExp
                        }
                    } else {
                        dimensions[subDimension] = subDimExp
                    }
                }
            }
            return dimensions
        }
    }
    
    /// Return a string symbol representing the unit
    public var symbol: String {
        switch type {
        case .defined(let definition):
            return definition.symbol
        case .composite(_):
            let unitList = self.sortedUnits()
            var computedSymbol = ""
            for (subUnit, exp) in unitList {
                if exp != 0 {
                    var prefix = ""
                    if computedSymbol == "" {
                        if exp >= 0 {
                            prefix = ""
                        } else {
                            prefix = "1/"
                        }
                    } else {
                        if exp >= 0 {
                            prefix = "*"
                        } else {
                            prefix = "/"
                        }
                    }
                    let symbol = subUnit.symbol
                    var expStr = ""
                    if abs(exp) > 1 {
                        expStr = "^\(abs(exp))"
                    }
                    
                    computedSymbol += "\(prefix)\(symbol)\(expStr)"
                }
            }
            return computedSymbol
        }
    }
    
    // MARK: - Arithmatic
    
    /// Multiply one unit by another and return the resulting unit
    public static func * (lhs: Unit, rhs: Unit) -> Unit {
        var subUnits: [DefinedUnit: Int] = [:]
        
        switch lhs.type {
        case .defined(let lhsDefined):
            subUnits[lhsDefined] = 1
        case .composite(let lhsSubUnits):
            for (lhsSubUnit, lhsExp) in lhsSubUnits {
                subUnits[lhsSubUnit] = lhsExp
            }
        }
        
        switch rhs.type {
        case .defined(let rhsDefined):
            if let lhsExp = subUnits[rhsDefined] {
                let newExp = lhsExp + 1
                if newExp == 0 {
                    subUnits.removeValue(forKey: rhsDefined)
                } else {
                    subUnits[rhsDefined] = newExp
                }
            } else {
                subUnits[rhsDefined] = 1
            }
        case .composite(let rhsSubUnits):
            for (rhsSubUnit, rhsExp) in rhsSubUnits {
                if let lhsExp = subUnits[rhsSubUnit] {
                    let newExp = lhsExp + rhsExp
                    if newExp == 0 {
                        subUnits.removeValue(forKey: rhsSubUnit)
                    } else {
                        subUnits[rhsSubUnit] = newExp
                    }
                } else {
                    subUnits[rhsSubUnit] = rhsExp
                }
            }
        }
        
        return Unit(composedOf: subUnits)
    }
    
    /// Divide one unit by another and return the resulting unit
    public static func / (lhs: Unit, rhs: Unit) -> Unit {
        var subUnits: [DefinedUnit: Int] = [:]
        
        switch lhs.type {
        case .defined(let lhsDefined):
            subUnits[lhsDefined] = 1
        case .composite(let lhsSubUnits):
            for (lhsSubUnit, lhsExp) in lhsSubUnits {
                subUnits[lhsSubUnit] = lhsExp
            }
        }
        
        switch rhs.type {
        case .defined(let rhsDefined):
            if let lhsExp = subUnits[rhsDefined] {
                let newExp = lhsExp - 1
                if newExp == 0 {
                    subUnits.removeValue(forKey: rhsDefined)
                } else {
                    subUnits[rhsDefined] = newExp
                }
            } else {
                subUnits[rhsDefined] = -1
            }
        case .composite(let rhsSubUnits):
            for (rhsSubUnit, rhsExp) in rhsSubUnits {
                if let lhsExp = subUnits[rhsSubUnit] {
                    let newExp = lhsExp - rhsExp
                    if newExp == 0 {
                        subUnits.removeValue(forKey: rhsSubUnit)
                    } else {
                        subUnits[rhsSubUnit] = newExp
                    }
                } else {
                    subUnits[rhsSubUnit] = -1 * rhsExp
                }
            }
        }
        return Unit(composedOf: subUnits)
    }
    
    /// Raise this unit to the given power
    public func pow(_ raiseTo: Int) -> Unit {
        var newSubUnits: [DefinedUnit: Int] = [:]
        
        switch self.type {
        case .defined(let defined):
            newSubUnits[defined] = raiseTo
        case .composite(let subUnits):
            newSubUnits = subUnits.mapValues { subExp in
                subExp * raiseTo
            }
        }
        return Unit(composedOf: newSubUnits)
    }
    
    // MARK: - Conversions
    
    /// Boolean indicating whether this unit and the input unit are of the same dimension
    public func isDimensionallyEquivalent(to: Unit) -> Bool {
        return self.dimension == to.dimension
    }
    
    /// Convert a number to its base value, as defined by the coefficient and constant
    func toBaseUnit(_ number: Double) throws -> Double {
        switch self.type {
        case .defined(let defined):
            return number * defined.coefficient + defined.constant
        case .composite(let subUnits):
            var totalCoefficient = 1.0
            for (subUnit, exponent) in subUnits {
                guard subUnit.constant == 0 else { // subUnit must not have constant
                    throw UnitsError.invalidCompositeUnit(message: "Nonlinear unit prevents conversion: \(subUnit)")
                }
                totalCoefficient *= Foundation.pow(subUnit.coefficient, Double(exponent))
            }
            return number * totalCoefficient
        }
    }
    
    /// Convert a number from its base value, as defined by the coefficient and constant
    func fromBaseUnit(_ number: Double) throws -> Double {
        switch self.type {
        case .defined(let defined):
            return (number - defined.constant) / defined.coefficient
        case .composite(let subUnits):
            var totalCoefficient = 1.0
            for (subUnit, exponent) in subUnits {
                guard subUnit.constant == 0 else { // subUnit must not have constant
                    throw UnitsError.invalidCompositeUnit(message: "Nonlinear unit prevents conversion: \(subUnit)")
                }
                totalCoefficient *= Foundation.pow(subUnit.coefficient, Double(exponent))
            }
            return number / totalCoefficient
        }
    }
    
    // MARK: - Private helpers
    
    /// Sort units into positive and negative groups, each going from smallest to largest exponent,
    /// with each in alphabetical order by symbol
    private func sortedUnits() -> [(DefinedUnit, Int)] {
        switch self.type {
        case .defined(let defined):
            return [(defined, 1)]
        case .composite(let subUnits):
            var unitList = [(DefinedUnit, Int)]()
            for (subUnit, exp) in subUnits {
                unitList.append((subUnit, exp))
            }
            unitList.sort { lhs, rhs in
                if lhs.1 > 0 && rhs.1 > 0 {
                    if lhs.1 == rhs.1 {
                        return lhs.0.symbol < rhs.0.symbol
                    } else {
                        return lhs.1 < rhs.1
                    }
                } else if lhs.1 > 0 && rhs.1 < 0 {
                    return true
                } else if lhs.1 < 0 && rhs.1 > 0 {
                    return false
                } else { // lhs.1 < 0 && rhs.1 > 0
                    if lhs.1 == rhs.1 {
                        return lhs.0.symbol < rhs.0.symbol
                    } else {
                        return lhs.1 > rhs.1
                    }
                }
            }
            return unitList
        }
    }
}

extension Unit: CustomStringConvertible {
    public var description: String {
        return symbol
    }
}

extension Unit: Equatable {
    public static func == (lhs: Unit, rhs: Unit) -> Bool {
        // TODO: Consider if there's a more explicit way to compute equality
        return lhs.symbol == rhs.symbol
    }
}

/// The two possible types of unit - predefined or composite
private enum UnitType {
    case defined(DefinedUnit)
    case composite([DefinedUnit: Int])
}

/// A predefined unit, which has quantity, symbol, and conversion information
private struct DefinedUnit {
    let dimension: [Quantity: Int]
    let symbol: String
    let coefficient: Double
    let constant: Double
}

extension DefinedUnit: Hashable {
    // TODO: We assume that symbol is completely unique. Perhaps create a unit registry to ensure this?
    public func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
}
