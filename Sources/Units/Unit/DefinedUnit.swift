/// A predefined unit, which has an identifying symbol, defined quantity, and conversion information.
struct DefinedUnit: Hashable, Sendable {
    let name: String
    let symbol: String
    let dimension: [Quantity: Int]
    let coefficient: Double
    let constant: Double

    init(name: String, symbol: String, dimension: [Quantity: Int], coefficient: Double = 1, constant: Double = 0) throws {
        guard !symbol.isEmpty else {
            throw UnitError.invalidSymbol(message: "Symbol cannot be empty")
        }
        for operatorSymbol in OperatorSymbols.allCases {
            guard !symbol.contains(operatorSymbol.rawValue) else {
                throw UnitError.invalidSymbol(message: "'\(name)' Symbol cannot contain '\(operatorSymbol.rawValue)'")
            }
        }
        guard !symbol.contains(" ") else {
            throw UnitError.invalidSymbol(message: "'\(name)' Symbol cannot contain spaces")
        }

        self.name = name
        self.symbol = symbol
        self.dimension = dimension
        self.coefficient = coefficient
        self.constant = constant
    }

    init(name: String, symbol: String, composedOf subUnits: [Unit: Int], coefficient: Double = 1, constant: Double = 0) throws {
        let uncomposableUnits = subUnits.keys.filter({ !$0.isComposable })
        guard uncomposableUnits.isEmpty else {
            throw UnitError.invalidCompositeUnit(message: "Nonlinear unit prevents composition: \(uncomposableUnits)")
        }

        let dimension = subUnits.reducedQuantities()
        try self.init(name: name, symbol: symbol, dimension: dimension, coefficient: coefficient, constant: constant)
    }
}

extension DefinedUnit: Equatable {
    public static func == (lhs: DefinedUnit, rhs: DefinedUnit) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}

fileprivate extension Dictionary<Unit, Int> {
    func reducedQuantities() -> [Quantity: Int] {
        self.reduce(into: [Quantity: Int](), { quantities, pair in
            let (unit, unitExponent) = pair
            for (quantity, quantityExponent) in unit.dimension {
                quantities[quantity, default: 0] += quantityExponent * unitExponent
                if quantities[quantity] == 0 { quantities.removeValue(forKey: quantity) }
            }
        })
    }

    func reducedCoefficient() -> Double {
        self.reduce(1, { $0 * $1.key.subUnits })
    }
}
