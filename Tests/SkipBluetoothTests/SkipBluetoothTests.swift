// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import XCTest
import OSLog
import Foundation
@testable import SkipBluetooth

let logger: Logger = Logger(subsystem: "SkipBluetooth", category: "Tests")

@available(macOS 13, *)
final class SkipBluetoothTests: XCTestCase {
    func testSkipBluetooth() throws {
        logger.log("running testSkipBluetooth")
        XCTAssertEqual(1 + 2, 3, "basic test")
        
        // load the TestData.json file from the Resources folder and decode it into a struct
        let resourceURL: URL = try XCTUnwrap(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let testData = try JSONDecoder().decode(TestData.self, from: Data(contentsOf: resourceURL))
        XCTAssertEqual("SkipBluetooth", testData.testModuleName)
    }
}

struct TestData : Codable, Hashable {
    var testModuleName: String
}