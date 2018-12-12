//
//  DateConverterTest.swift
//  TriggerTests
//
//  Created by Azadeh Bagheri (LCL) on 12/12/18.
//

import XCTest
@testable import Trigger

class DateConverterTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testDateConvertion() {
        let iso8601Date = "2018-12-12T22:40:38Z"
        let expectedDate = "Dec 12, 2018 at 5:40:38 PM"
        let date = DateConverter.convert(from: iso8601Date)
        XCTAssert(date == expectedDate, "Date was not coverted properly")
    }
    static var allTests = [
        ("testDateConvertion", testDateConvertion)
    ]
}
