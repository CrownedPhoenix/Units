import Foundation

public struct Unit {
    
    private let type: UnitType
    
    public init(fromSymbol symbol: String) throws {
        if symbol.contains("*") || symbol.contains("/") || symbol.contains("^") {
            let compositeUnits = try UnitRegistry.instance.compositeUnitsFromSymbol(symbol: symbol)
            self.init(composedOf: compositeUnits)
        } else {
            let definedUnit = try UnitRegistry.instance.definedUnitFromSymbol(symbol: symbol)
            self.init(definedBy: definedUnit)
        }
    }
    
    /// Create a new from the defined unit object.
    /// - parameter definedBy: A defined unit to wrap
    internal init(definedBy: DefinedUnit) {
        self.type = .defined(definedBy)
    }
    
    /// Create a new from the sub-unit map.
    /// - parameter composedOf: A dictionary of defined units and exponents. If this dictionary only has one value with an exponent of one,
    /// we return it as that defined unit.
    internal init(composedOf subUnits: [DefinedUnit: Int]) {
        if subUnits.count == 1, let subUnit = subUnits.first, subUnit.value == 1 {
            self.type = .defined(subUnit.key)
        } else {
            self.type = .composite(subUnits)
        }
    }
    
    /// Define a new unit to add to the registry
    /// - parameter name: The string name of the unit.
    /// - parameter symbol: The string symbol of the unit. Symbols may not contain the characters `*`, `/`, or `^`.
    /// - parameter dimension: The unit dimensionality as a dictionary of quantities and their respective exponents.
    /// - parameter coefficient: The value to multiply a base unit of this dimension when converting it to this unit. For base units, this is 1.
    /// - parameter constant: The value to add to a base unit when converting it to this unit. This is added after the coefficient is multiplied according to order-of-operations.
    @discardableResult
    public static func define(
        name: String,
        symbol: String,
        dimension: [Quantity: Int],
        coefficient: Double = 1,
        constant: Double = 0
    ) throws -> Unit {
        try UnitRegistry.instance.addUnit(
            name: name,
            symbol: symbol,
            dimension: dimension,
            coefficient: coefficient,
            constant: constant
        )
        return try Unit(fromSymbol: symbol)
    }
    
    /// Return a list of all currently defined units
    public static func allDefined() -> [Unit] {
        UnitRegistry.instance.allUnits()
    }
    
    /// Return the dimension of the unit in terms of base quanties
    public var dimension: [Quantity: Int] {
        switch type {
        case .defined(let definition):
            return definition.dimension
        case .composite(let subUnits):
            var dimensions: [Quantity: Int] = [:]
            for (subUnit, exp) in subUnits {
                let subDimensions = subUnit.dimension.mapValues { value in
                    exp * value
                }
                dimensions.merge(subDimensions) { existingExp, subDimensionExp in
                    existingExp + subDimensionExp
                }
            }
            return dimensions.filter { (key, value) in
               value != 0
            }
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
                guard exp != 0 else {
                    break
                }
                
                var prefix = ""
                if computedSymbol == "" { // first symbol
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
            return computedSymbol
        }
    }
    
    /// Return a string name representing the unit
    public var name: String {
        switch type {
        case .defined(let definition):
            return definition.name
        case .composite(_):
            let unitList = self.sortedUnits()
            var computedName = ""
            for (subUnit, exp) in unitList {
                guard exp != 0 else {
                    break
                }
                
                var prefix = ""
                if computedName == "" { // first name
                    if exp >= 0 {
                        prefix = ""
                    } else {
                        prefix = "1 / "
                    }
                } else {
                    if exp >= 0 {
                        prefix = " * "
                    } else {
                        prefix = " / "
                    }
                }
                let name = subUnit.name
                var expStr = ""
                if abs(exp) > 1 {
                    expStr = "^\(abs(exp))"
                }
                
                computedName += "\(prefix)\(name)\(expStr)"
            }
            return computedName
        }
    }
    
    // MARK: - Arithmatic
    
    /// Multiply one unit by another and return the resulting unit
    public static func * (lhs: Unit, rhs: Unit) -> Unit {
        let lhsUnits = lhs.subUnits
        let rhsUnits = rhs.subUnits
        
        var subUnits = lhsUnits
        subUnits.merge(rhsUnits) { lhsUnitExp, rhsUnitExp in
            lhsUnitExp + rhsUnitExp
        }
        subUnits = subUnits.filter { (key, value) in
            value != 0
        }
        
        return Unit(composedOf: subUnits)
    }
    
    /// Divide one unit by another and return the resulting unit
    public static func / (lhs: Unit, rhs: Unit) -> Unit {
        let lhsUnits = lhs.subUnits
        let rhsUnits = rhs.subUnits
        
        let negRhsUnits = rhsUnits.mapValues { rhsUnitExp in
            -1 * rhsUnitExp
        }
        
        var subUnits = lhsUnits
        subUnits.merge(negRhsUnits) { lhsUnitExp, negRhsUnitExp in
            lhsUnitExp + negRhsUnitExp
        }
        subUnits = subUnits.filter { (key, value) in
            value != 0
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
                    throw UnitError.invalidCompositeUnit(message: "Nonlinear unit prevents conversion: \(subUnit)")
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
                    throw UnitError.invalidCompositeUnit(message: "Nonlinear unit prevents conversion: \(subUnit)")
                }
                totalCoefficient *= Foundation.pow(subUnit.coefficient, Double(exponent))
            }
            return number / totalCoefficient
        }
    }
    
    // MARK: - Private helpers
    
    /// Returns a dictionary that represents the unique defined units and their exponents. For a
    /// composite unit, this is simply the `subUnits`, but for a defined unit, this is `[self: 1]`
    private var subUnits: [DefinedUnit: Int] {
        switch self.type {
        case .defined(let defined):
            return [defined: 1]
        case .composite(let subUnits):
            return subUnits
        }
    }
    
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

extension Unit: Equatable {
    public static func == (lhs: Unit, rhs: Unit) -> Bool {
        switch lhs.type {
        case .defined(let lhsDefined):
            switch rhs.type {
            case .defined(let rhsDefined):
                return lhsDefined == rhsDefined
            case .composite(_):
                return false
            }
        case .composite(let lhsSubUnits):
            switch rhs.type {
            case .defined(_):
                return false
            case .composite(let rhsSubUnits):
                return lhsSubUnits == rhsSubUnits
            }
        }
    }
}

extension Unit: CustomStringConvertible {
    public var description: String {
        return symbol
    }
}

extension Unit: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(symbol)
    }
    
    public init(from: Decoder) throws {
        let symbol = try from.singleValueContainer().decode(String.self)
        try self.init(fromSymbol: symbol)
    }
}

/// The two possible types of unit - predefined or composite
private enum UnitType {
    case defined(DefinedUnit)
    case composite([DefinedUnit: Int])
}

/// A predefined unit, which has name, quantity, symbol, and conversion information
/// These should all be stored in the UnitRegistry, not directly created
struct DefinedUnit: Hashable {
    let name: String
    let symbol: String
    let dimension: [Quantity: Int]
    let coefficient: Double
    let constant: Double
    
    internal init(name: String, symbol: String, dimension: [Quantity: Int], coefficient: Double = 1, constant: Double = 0) throws {
        guard !symbol.contains("*") else {
            throw UnitError.invalidSymbol(message: "Symbol cannot contain '*'")
        }
        guard !symbol.contains("/") else {
            throw UnitError.invalidSymbol(message: "Symbol cannot contain '/'")
        }
        guard !symbol.contains("^") else {
            throw UnitError.invalidSymbol(message: "Symbol cannot contain '^'")
        }
        
        self.name = name
        self.symbol = symbol
        self.dimension = dimension
        self.coefficient = coefficient
        self.constant = constant
    }
}
