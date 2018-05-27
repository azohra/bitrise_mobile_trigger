// import Foundation
import XCTest

class TestObserver: NSObject, XCTestObservation {
    var testCaseTotal = 0
    var failedTC = 0

    func testBundleWillStart(_ testBundle: Bundle) {}

    func testBundleDidFinish(_ testBundle: Bundle) {}

    func testSuiteWillStart(_ testSuite: XCTestSuite) {}

    func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        // print("Total number of test cases: ", testCaseTotal)
        // print("Number of failed test cases: ", failedTC)
    }

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
        // print(">>>>>>>>>>>>>>>>>> test case failed message " + description)
        
        // print("$$$$$$$$$$$$$$$$$$  NAME: \(testCase.name) %%%%%%%%%%%%%%%%%%%%%%%%")
        // print("$$$$$$$$$$$$$$$$$$  TEST CASE COUNT: \(testCase.testCaseCount) %%%%%%%%%%%%%%%%%%%%%%%%")
        // print("$$$$$$$$$$$$  SUCCEED? " + String(describing: testCase.testRun?.hasSucceeded) + " %%%%%%%%%%%%%%%%%")
        // print("$$$$$$$$$$$$$$$$$$  EXECUTION COUNT: \(testCase.testRun?.executionCount) %%%%%%%%%%%%%%%%%%%%%%%%")
        // print("$$$$$$$$$$$$$$$$$$  FAILURE COUNT: \(testCase.testRun?.failureCount) %%%%%%%%%%%%%%%%%%%%%%%%")
        // print("$$$$$$$$$$$$$$$$$$  TEST CASE COUNT: \(testCase.testRun?.testCaseCount) %%%%%%%%%%%%%%%%%%%%%%%%")
        // print("$$$$$$$$$$$$$  TOTAL FAILURE COUNT: \(testCase.testRun?.totalFailureCount) %%%%%%%%%%%%%%%%%%")
        // print("$$$$$$$$$  UNEXPECTED EXCEPTION COUNT: \(testCase.testRun?.unexpectedExceptionCount) %%%%%%%%%%%%")
        
        // var tmpMsgArr = description.components(separatedBy: ".---")
        // let testcaseID = tmpMsgArr[0]

        // print("------" + testcaseID)

        // yourmethodThatwillbeCalledWhenTCFail() // implement this method that you want to execute

        failedTC += 1
    }

    func testCaseWillStart(_ testCase: XCTestCase) {}

    func testCaseDidFinish(_ testCase: XCTestCase) {
        testCaseTotal += 1       
    }
}
