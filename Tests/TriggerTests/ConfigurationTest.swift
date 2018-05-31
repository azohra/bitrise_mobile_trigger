import XCTest
@testable import Trigger

class Configuration: XCTestCase {
  override func setUp() {
    continueAfterFailure = true
  }

  func testReadConfigFile() {
    XCTAssertThrowsError(try Config.readConfigFile(path: "./fake/config/path")) { (error) -> Void in
      print(error)
    }
  }

  func testValidJsonToObject() {
    let validJson = """
    {
      "theAccessToken": "valid-access-token",
      "token": "valid-token",
      "slug": "valid-slug",
      "projectName": "mobile trigger app",
      "slackURL": "valid-slack-url"
    }
    """
    let json: Data = validJson.data(using: String.Encoding.utf8)!
    let projectConfig = try? Config(with: json)
    XCTAssert(projectConfig.theAccessToken == "valid-access-token", "Failed to get the access token")
    XCTAssert(projectConfig.token == "valid-token", "Failed to get the token")
    XCTAssert(projectConfig.slug == "valid-slug", "Failed to get the slug")
    XCTAssert(projectConfig.projectName == "mobile trigger app", "Failed to get the project name")
    XCTAssert(projectConfig.slackURL == "valid-slack-url", "Failed to get the slack url")
  }

  func testInvalidJsonToObject() {
    let invalidJson: Data = """
    {
      theAccessToken: "valid-access-token",
      token: "valid-token",
      slug: "valid-slug",
      projectName: "mobile trigger app",
      slackURL: "valid-slack-url"
    }
    """.data(using: String.Encoding.utf8)!

    XCTAssertThrowsError(try Config(with: invalidJson)) { (error) -> Void in
      print(":> ERROR CAUGHT: \(error)")
    }
  }
  
  func testJsonWithExtraKeys() {
    let extraKey: Data = """
    {
      "theAccessToken": "valid-access-token",
      "token": "valid-token",
      "slug": "valid-slug",
      "projectName": "mobile trigger app",
      "slackURL": "valid-slack-url",
      "extraKey": "extra-value"
    }
    """.data(using: String.Encoding.utf8)!
    
    let projectConfig = try? Config(with: extraKey)
    XCTAssert(projectConfig.theAccessToken == "valid-access-token", "Failed to get the access token")
    XCTAssert(projectConfig.token == "valid-token", "Failed to get the token")
    XCTAssert(projectConfig.slug == "valid-slug", "Failed to get the slug")
    XCTAssert(projectConfig.projectName == "mobile trigger app", "Failed to get the project name")
    XCTAssert(projectConfig.slackURL == "valid-slack-url", "Failed to get the slack url")
  }
  
  func testJsonWithMissingKeys() {
    let missingKeys: Data = """
    {
      "theAccessToken": "valid-access-token",
      "token": "valid-token",
    }
    """.data(using: String.Encoding.utf8)!
    
    XCTAssertThrowsError(try Config(with: missingKeys)) { (error) -> Void in
      print(":> ERROR CAUGHT: \(error)")
    }
  }
  
  static var allTests = [
    ("testReadConfigFile", testReadConfigFile),
    ("testValidJsonToObject", testValidJsonToObject),
    ("testInvalidJsonToObject", testInvalidJsonToObject),
    ("testJsonWithExtraKeys", testJsonWithExtraKeys),
    ("testJsonWithMissingKeys", testJsonWithMissingKeys)
  ]
}
