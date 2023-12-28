/// UnitRegistry defines a structure that contains all defined units. This ensures
/// that we are able to parse to and from unit symbol representations.
internal class Registry {
    // TODO: Should we eliminate this singleton and make clients keep track?
    internal static let instance = Registry()

    // Quick access based on symbol
    private var symbolMap: [String: Unit]
    // Quick access based on name
    private var nameMap: [String: Unit]

    private init() {
        symbolMap = [:]
        nameMap = [:]
    }

    /// Returns a list of defined units and their exponents, given a composite unit symbol. It is expected that the caller has
    /// verified that this is a composite unit.
    internal func compositeUnitsFromSymbol(symbol: String) throws -> [Unit: Int] {
        let symbolsAndExponents = try deserializeSymbolicEquation(symbol)

        var compositeUnits = [Unit: Int]()
        for (definedUnitSymbol, exponent) in symbolsAndExponents {
            guard exponent != 0 else {
                continue
            }
            let definedUnit = try getUnit(bySymbol: definedUnitSymbol)
            compositeUnits[definedUnit] = exponent
        }
        return compositeUnits
    }

    /// Returns a defined unit given a defined unit symbol. It is expected that the caller has
    /// verified that this is not a composite unit.
    internal func getUnit(bySymbol symbol: String) throws -> Unit {
        guard let definedUnit = symbolMap[symbol] else {
            throw UnitError.unitNotFound(message: "Symbol '\(symbol)' not recognized")
        }
        return definedUnit
    }

    /// Returns a defined unit given a defined unit name. It is expected that the caller has
    /// verified that this is not a composite unit.
    internal func getUnit(byName name: String) throws -> Unit {
        guard let definedUnit = nameMap[name] else {
            throw UnitError.unitNotFound(message: "Name '\(name)' not recognized")
        }
        return definedUnit
    }

    /// Define a new unit to add to the registry
    /// - parameter name: The string name of the unit.
    /// - parameter symbol: The string symbol of the unit. Symbols may not contain the characters `*`, `/`, or `^`.
    /// - parameter dimension: The unit dimensionality as a dictionary of quantities and their respective exponents.
    /// - parameter coefficient: The value to multiply a base unit of this dimension when converting it to this unit. For base units, this is 1.
    /// - parameter constant: The value to add to a base unit when converting it to this unit. This is added after the coefficient is multiplied according to order-of-operations.
    internal func addUnit(
        name: String,
        symbol: String,
        dimension: [Dimension: Int],
        coefficient: Double = 1
    ) throws {
        let newUnit = Unit(
            dimension: dimension,
            coefficient: coefficient
        )
        // Protect against double-defining symbols
        if symbolMap[symbol] != nil {
            throw UnitError.invalidSymbol(message: "Duplicate symbol: \(symbol)")
        }
        symbolMap[symbol] = newUnit

        // Protect against double-defining names
        if nameMap[name] != nil {
            fatalError("Duplicate name: \(name)")
        }
        nameMap[name] = newUnit
    }

    /// Returns all units currently defined by the registry
    internal func allUnits() -> [Unit] {
        Array(symbolMap.values)
    }
}
