import XCTest
@testable import Trigger

class BuildStatusMessage: XCTestCase {
  override class func setUp() {
    let testObserver = TestObserver()
    XCTestObservationCenter.shared.addTestObserver(testObserver)
  }
  
  private let timeOutMsg = "Build TIMED OUT base on mobile trigger internal setting"
  private let successMsg = "Build finished, with success"
  private let errorMsg = "Build finished, with error"
  private let abortMsg = "Build was aborted"
  private let strangeThingOccurredMsg = "Build status did not match any of the values 0, 1, 2 or 3.\n This is very strange!"
  private var bitriseClient: BitriseClient?
  
  private func getBitriseClient() -> BitriseClient {
   if let bClient = bitriseClient {
     return bClient
   }
   return BitriseClient()
  }
  
  func testBuildTimedOutMessage() {
      let msg = getBitriseClient().buildStatusMessage(0)
      XCTAssert(timeOutMsg == msg, "Message for build timeouts did not match.")
  }

  func testBuildSuccessMessage() {
    let msg = getBitriseClient().buildStatusMessage(1)
    XCTAssert(successMsg == msg, "Message for build success did not match.")
  }

  func testBuildFailedMessage() {
    let msg = getBitriseClient().buildStatusMessage(2)
    XCTAssert(errorMsg == msg, "Message for build error did not match.")
  }
  
  func testBuildAbortedMessage() {
    let msg = getBitriseClient().buildStatusMessage(3)
    XCTAssert(abortMsg == msg, "Message for aborting build did not match.")
  }

  func testStrangeThingOccurredMessage() {
    // Any value other than 0 ... 3 should return this message
    let msg = getBitriseClient().buildStatusMessage(5)
    XCTAssert(strangeThingOccurredMsg == msg, "Message for something strange happened did not match.")
  }
  
  static var allTests = [
      ("testBuildTimedOutMessage", testBuildTimedOutMessage),
      ("testBuildSuccessMessage", testBuildSuccessMessage),
      ("testBuildFailedMessage", testBuildFailedMessage),
      ("testBuildAbortedMessage", testBuildAbortedMessage),
      ("testStrangeThingOccurredMessage", testStrangeThingOccurredMessage)
  ]
}
