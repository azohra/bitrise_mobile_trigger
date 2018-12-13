import XCTest
@testable import Trigger

class DateConverterTest: XCTestCase {

    func testDateConversion() {
        let iso8601Date = "2018-12-12T22:40:38Z"
        let expectedDate = "Dec 12, 2018 at 5:40:38 PM"
        let date = DateConverter.convert(from: iso8601Date)
        XCTAssert(date == expectedDate, """
            Date was not coverted properly. Result date is: \(date), while expected date is: \(expectedDate)
            """
        )}
    
    static var allTests = [
        ("testDateConversion", testDateConversion)
    ]
}
