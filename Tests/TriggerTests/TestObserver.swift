// Stubbed out for customized test reporting
import XCTest

class TestObserver: NSObject, XCTestObservation {
    var testCaseTotal = 0
    var failedTC = 0

    func testBundleWillStart(_ testBundle: Bundle) {}

    func testBundleDidFinish(_ testBundle: Bundle) {}

    func testSuiteWillStart(_ testSuite: XCTestSuite) {}

    func testSuiteDidFinish(_ testSuite: XCTestSuite) {}

    func testSuite(
      _ testSuite: XCTestSuite,
      didFailWithDescription description: String,
      inFile filePath: String?,
      atLine lineNumber: Int
      ) {}

    func testCase(
      _ testCase: XCTestCase,
      didFailWithDescription description: String,
      inFile filePath: String?,
      atLine lineNumber: Int) {
        failedTC += 1
    }

    func testCaseWillStart(_ testCase: XCTestCase) {}

    func testCaseDidFinish(_ testCase: XCTestCase) {
        testCaseTotal += 1       
    }
}
