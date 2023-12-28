private extension Dimension {
    var base: Unit { Unit(dimension: [self: 1]) }
}

public extension Unit {

    static let unitless = Unit(dimension: [:])

    // MARK: Amount
    static let mole = Dimension.mole.base

    // MARK: Current
    static let ampere = Dimension.ampere.base

    // MARK: Length
    static let meter = Dimension.meter.base

    // MARK: Mass
    static let kilogram = Dimension.kilogram.base

    // MARK: Temperature
    static let kelvin = Dimension.kelvin.base

    // MARK: Time
    static let second = Dimension.second.base


    // MARK: Luminous Intensity
    static let candela = Dimension.candela.base

    // MARK: Angle
    static let radian = Dimension.radian.base

    // MARK: Data
    static let bit = Dimension.bit.base
}


public extension Unit {
    // MARK: Acceleration
    static let standardGravity = (9.80665 * .meter) / .second.pow(2)

    // MARK: Amount
    static let millimole = 0.001 * .mole
    static let particle = 6.02214076e-23 * .mole

    // MARK: Angle
    static let degree = (180 / Double.pi) * .radian
    static let revolution = 2 * Double.pi * .radian

    // MARK: Area
    static let acre = 4046.8564224 * .meter.pow(2)
    static let are = 100 * .meter
    static let hectare = 100 * .are

    // MARK: Capacitance
    static let farad = (.second.pow(4) * .ampere.pow(2)) / (.meter.pow(2) * .kilogram)

    // MARK: Charge


    // MARK: Current
    static let microampere = 0.001 * .milliampere
    static let milliampere = 0.001 * .ampere
    static let kiloampere = 1000 * .ampere
    static let megaampere = 1000 * .kiloampere

    // MARK: Data
    static let byte = 8 * .bit
    static let kilobyte = 1000 * .byte
    static let megabyte = 1000 * .kilobyte
    static let gigabyte = 1000 * .megabyte
    static let terabyte = 1000 * .gigabyte
    static let petabyte = 1000 * .terabyte

    // MARK: Electric Potential Difference
    static let volt = (.kilogram * .meter.pow(2)) / (.second.pow(3) * .ampere)
    static let microvolt = 0.001 * .millivolt
    static let millivolt = 0.001 * .volt
    static let kilovolt = 1000 * .volt
    static let megavolt = 1000 * .kilovolt

    // MARK: Energy
    static let joule = (.kilogram * .meter.pow(2)) / .second.pow(2)
    static let kilojoule = 1000 * .joule
    static let megajoule = 1000 * .kilojoule

    static let calorie = 4.184 * .joule
    static let kilocalorie = 1000 * .calorie

    static let electronVolt = 1.602176634e-19 * .joule

    // MARK: Force
    static let newton = (.kilogram * .meter) / .second.pow(2)
    static let poundForce = 4.448222 * .newton

    // MARK: Frequency
    static let nanohertz = 0.001 * .microhertz
    static let microhertz = 0.001 * millihertz
    static let millihertz = 0.001 * .hertz
    static let hertz = Unit.second.pow(-1)
    static let kilohertz = 1000 * .hertz
    static let megahertz = 1000 * .kilohertz
    static let gigahertz = 1000 * .megahertz
    static let terahertz = 1000 * .gigahertz

    // MARK: Illuminance
    static let lux = (.candela * .radian.pow(2)) / .meter.pow(2)
    static let footCandle = 10.76 * .lux
    static let phot = 10_000 * .lux

    // MARK: Inductance
    static let henry = (.kilogram * .meter.pow(2)) / (.second.pow(2) * .ampere.pow(2))

    // MARK: Length
    static let picometer = 0.01 * .nanometer
    static let nanometer = 0.01 * .micrometer
    static let micrometer = 0.01 * .millimeter
    static let millimeter = 0.01 * .centimeter
    static let centimeter = 0.01 * .meter
    static let decameter = 10 * .meter
    static let hectometer = 100 * .meter
    static let kilometer = 1000 * .meter
    static let megameter = 1000 * .kilometer

    static let inch = 2.54 * .centimeter
    static let foot = 12 * .inch
    static let yard = 3 * .foot
    static let mile = 5280 * .foot

    // MARK: Luminous Intensity

    // MARK: Mass
    static let pound = 0.45359237 * .kilogram

    // MARK: Power
    static let femptowatt = 0.001 * .picowatt
    static let picowatt = 0.001 * .nanowatt
    static let nanowatt = 0.001 * .microwatt
    static let microwatt = 0.001 * .milliwatt
    static let milliwatt = 0.001 * .watt
    static let watt = (.kilogram * .meter.pow(2)) / .second.pow(3)
    static let kilowatt = 1000 * .watt
    static let megawatt = 1000 * .kilowatt
    static let gigawatt = 1000 * .megawatt
    static let terawatt = 1000 * .gigawatt

    // MARK: Pressure

    static let pascal = .kilogram / (.meter * .second.pow(2))
    static let kilopascal = 1000.0 * .pascal
    static let bar = 100 * .kilopascal

    // MARK: Temperature

    // MARK: Time
    static let minute = 60 * .second
    static let hour = 60 * .minute
    static let day = 24 * .hour
    static let week = 7 * .day
}

public extension Unit {
    static let celsius = Unit(dimension: [.kelvin: 1], constant: 273.15)
    static let fahrenheit = Unit(
        dimension: [.kelvin: 1],
        coefficient: 5.0 / 9.0,
        constant: (459.67 * 5.0 / 9.0)
    )
}
