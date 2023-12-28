@testable import Units
import XCTest

final class BimapTests: XCTestCase {
    

    func testBimap() {
        var bimap = Bimap<Units.Unit, String>()

        bimap[Unit.foot] = ["feet", "ft"]
        XCTAssertEqual(bimap["feet"], Unit.foot)
        XCTAssertEqual(bimap["ft"], Unit.foot)
        XCTAssertEqual(bimap[Unit.foot], ["feet", "ft"])

        bimap[Unit.foot] = ["ft"]
        XCTAssertNil(bimap["feet"])
        XCTAssertEqual(bimap["ft"], Unit.foot)
        XCTAssertEqual(bimap[Unit.foot], ["ft"])

        bimap[Unit.foot] = ["feet", "ft"]
        XCTAssertEqual(bimap["feet"], Unit.foot)
        XCTAssertEqual(bimap["ft"], Unit.foot)
        XCTAssertEqual(bimap[Unit.foot], ["feet", "ft"])

        bimap[Unit.foot] = []
        XCTAssertNil(bimap["feet"])
        XCTAssertNil(bimap["ft"])
        XCTAssertEqual(bimap[Unit.foot], [])

        bimap[Unit.mile] = ["mile", "m"]
        bimap[Unit.meter] = ["meter", "m"]
        XCTAssertEqual(bimap["mile"], Unit.mile)
        XCTAssertEqual(bimap["m"], Unit.meter)
        XCTAssertEqual(bimap["meter"], Unit.meter)
        XCTAssertEqual(bimap[Unit.mile], ["mile"])
        XCTAssertEqual(bimap[Unit.meter], ["meter", "m"])

        bimap[Unit.mile] = []
        XCTAssertNil(bimap["mile"])
        XCTAssertEqual(bimap["m"], Unit.meter)
        XCTAssertEqual(bimap["meter"], Unit.meter)
        XCTAssertEqual(bimap[Unit.mile], [])
        XCTAssertEqual(bimap[Unit.meter], ["meter", "m"])

        bimap["m"] = Unit.mile
        XCTAssertNil(bimap["mile"])
        XCTAssertEqual(bimap["m"], Unit.mile)
        XCTAssertEqual(bimap["meter"], Unit.meter)
        XCTAssertEqual(bimap[Unit.mile], ["m"])
        XCTAssertEqual(bimap[Unit.meter], ["meter"])
    }
}
