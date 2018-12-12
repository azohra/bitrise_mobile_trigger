import XCTest

#if os(Linux)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BuildStatusMessageTest.allTests),
        testCase(ConfigurationTest.allTests),
        testCase(HTTPRequestTest.allTests),
        testCase(DateConverterTest.allTests)
    ]
}
#endif
