import XCTest
@testable import Trigger

class HTTPRequestTest: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = true
    }
    
    func testRequestGeneration() {
        let endpoint = "https://api.bitrise.io/v0.1/apps/pAbrt6547des/builds/Byt6754esr43"
        let headers = ["Content-Type": "application/json", "Authorization": "theAccessToken"]
        var testRequestGenerator = RequestGenerator(url: endpoint, method: .get, headers: headers, body: nil)
        let request = testRequestGenerator.generateRequest()
        
        XCTAssert(request.url?.absoluteString == endpoint, "the request url is not set properly." )
        XCTAssert(request.httpMethod == "GET", "the request method is not set properly.")
        XCTAssert(request.allHTTPHeaderFields! == headers, "the request header is not set properly.")
        XCTAssert(request.httpBody == nil, "the request body is not set properly.")
    }
    
    static var allTests = [
        ("testRequestGeneration", testRequestGeneration)
   ]
}
