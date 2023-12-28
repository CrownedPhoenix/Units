

extension Unit {
    static let symbols: Bimap<Unit, String> = {
        let mappings: [Unit: Set<String>] = [
            Unit.unitless: [],
            Unit.mole: [],
            Unit.ampere: [],
            Unit.meter: [],
            Unit.kilogram: [],
            Unit.kelvin: [],
            Unit.second: [],
            Unit.candela: [],
            Unit.radian: [],
            Unit.bit: [],
            Unit.millimole: [],
            Unit.particle: [],
            Unit.microampere: [],
            Unit.milliampere: [],
            Unit.kiloampere: [],
            Unit.megaampere: [],
            Unit.picometer: [],
            Unit.nanometer: [],
            Unit.micrometer: [],
            Unit.millimeter: [],
            Unit.centimeter: [],
            Unit.decameter: [],
            Unit.hectometer: [],
            Unit.kilometer: [],
            Unit.megameter: [],
            Unit.inch: [],
            Unit.foot: [],
            Unit.yard: [],
            Unit.mile: [],
            Unit.pound: [],
            Unit.minute: [],
            Unit.hour: [],
            Unit.day: [],
            Unit.week: [],
            Unit.degree: [],
            Unit.revolution: [],
            Unit.byte: [],
            Unit.kilobyte: [],
            Unit.megabyte: [],
            Unit.gigabyte: [],
            Unit.terabyte: [],
            Unit.petabyte: [],
            Unit.standardGravity: [],
            Unit.acre: [],
            Unit.are: [],
            Unit.hectare: [],
            Unit.farad: [],
            Unit.volt: [],
            Unit.microvolt: [],
            Unit.millivolt: [],
            Unit.kilovolt: [],
            Unit.megavolt: [],
            Unit.joule: [],
            Unit.kilojoule: [],
            Unit.megajoule: [],
            Unit.calorie: [],
            Unit.kilocalorie: [],
            Unit.electronVolt: [],
            Unit.newton: [],
            Unit.poundForce: [],
            Unit.nanohertz: [],
            Unit.microhertz: [],
            Unit.millihertz: [],
            Unit.hertz: [],
            Unit.kilohertz: [],
            Unit.megahertz: [],
            Unit.gigahertz: [],
            Unit.terahertz: [],
            Unit.lux: [],
            Unit.footCandle: [],
            Unit.phot: [],
            Unit.henry: [],
            Unit.femptowatt: [],
            Unit.picowatt: [],
            Unit.nanowatt: [],
            Unit.microwatt: [],
            Unit.milliwatt: [],
            Unit.watt: [],
            Unit.kilowatt: [],
            Unit.megawatt: [],
            Unit.gigawatt: [],
            Unit.terawatt: [],
            Unit.celsius: [],
            Unit.fahrenheit: [],
        ]
        return mappings.reduce(into: Bimap(), { $0[$1.key] = $1.value })
    }()
}

struct Bimap<Parent: Hashable, Child: Hashable> {
    var parentToChild: [Parent: Set<Child>] = [:]
    var childToParent: [Child: Parent] = [:]

    subscript(_ parent: Parent) -> Set<Child> {
        get { parentToChild[parent] ?? [] }
        set {
            // For all existing children, remove parent
            parentToChild[parent]?.forEach({ childToParent[$0] = nil })
            
            // For all new children, remove existing parent
            newValue.forEach({
                if let existingParent = childToParent[$0] {
                    parentToChild[existingParent]?.remove($0)
                }
                childToParent[$0] = nil
            })

            // For parent, set new children
            parentToChild[parent] = newValue
            // For new children, set parent
            newValue.forEach({ childToParent[$0] = parent })
        }
    }

    subscript(_ child: Child) -> Parent? {
        get { childToParent[child] }
        set {
            // For existing parent, remove child
            if let existingParent = childToParent[child] {
                childToParent[child] = nil
                parentToChild[existingParent]?.remove(child)
            }

            // For new parent, add child
            if let newValue {
                parentToChild[newValue, default: []].insert(child)
            }
            // For child, add new parent
            childToParent[child] = newValue
        }
    }
}
