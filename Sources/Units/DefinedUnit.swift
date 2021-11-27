/// A predefined unit, which has an identifying symbol, defined quantity, and conversion information.
struct DefinedUnit: Hashable {
    let name: String
    let symbol: String
    let dimension: [Quantity: Int]
    let coefficient: Double
    let constant: Double

    init(name: String, symbol: String, dimension: [Quantity: Int], coefficient: Double = 1, constant: Double = 0) throws {
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
