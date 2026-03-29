// Copyright 2025–2026 Skip
// SPDX-License-Identifier: MPL-2.0
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
