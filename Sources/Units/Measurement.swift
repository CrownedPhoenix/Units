import Foundation

/// Models a value with a unit
public struct Measurement: Equatable {
    public let value: Double
    public let unit: Unit
    
    public func isDimensionallyEquivalent(to: Measurement) -> Bool {
        return self.unit.isDimensionallyEquivalent(to: to.unit)
    }
    
    public func pow(_ raiseTo: Int) -> Measurement {
        return Measurement(
            value: Foundation.pow(self.value, Double(raiseTo)),
            unit: self.unit.pow(raiseTo)
        )
    }
    
    /// Return a measurement of the same value, but with the provided unit. That is,
    /// the value **is not matematically converted**.
    public func declare(as newUnit: Unit) -> Measurement {
        return Measurement(value: value, unit: newUnit)
    }
    
    /// Convert this unit to the provided one, and return the result. The provided unit must
    /// be dimensionally equivalent to this measurement's unit.
    public func convert(to newUnit: Unit) throws -> Measurement {
        guard unit.isDimensionallyEquivalent(to: newUnit) else {
            throw UnitsError.incompatibleUnits(message: "Cannot convert \(unit) to \(newUnit)")
        }
        let baseValue = try self.unit.toBaseUnit(self.value)
        let convertedValue = try newUnit.fromBaseUnit(baseValue)
        return Measurement(value: convertedValue, unit: newUnit)
    }
    
    public static func + (lhs: Measurement, rhs: Measurement) throws -> Measurement {
        guard lhs.unit == rhs.unit else {
            throw UnitsError.incompatibleUnits(message: "Incompatible units: \(lhs.unit) != \(rhs.unit)")
        }
        
        return Measurement(
            value: lhs.value + rhs.value,
            unit: lhs.unit
        )
    }
    
    public static func - (lhs: Measurement, rhs: Measurement) throws -> Measurement {
        guard lhs.unit == rhs.unit else {
            throw UnitsError.incompatibleUnits(message: "Incompatible units: \(lhs.unit) != \(rhs.unit)")
        }
        
        return Measurement(
            value: lhs.value - rhs.value,
            unit: lhs.unit
        )
    }
    
    public static func * (lhs: Measurement, rhs: Measurement) -> Measurement {
        return Measurement(
            value: lhs.value * rhs.value,
            unit: lhs.unit * rhs.unit
        )
    }
    
    public static func / (lhs: Measurement, rhs: Measurement) -> Measurement {
        return Measurement(
            value: lhs.value / rhs.value,
            unit: lhs.unit / rhs.unit
        )
    }
}

extension Measurement: CustomStringConvertible {
    public var description: String {
        return "\(value)\(unit)"
    }
}
