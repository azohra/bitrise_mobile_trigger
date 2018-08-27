import XCTest

#if os(Linux)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BuildStatusMessageTest.allTests),
        testCase(ConfigurationTest.allTests),
        testCase(RequestGeneratorTest.allTests)
    ]
}
#endif
