import Foundation

public enum StatusCode {
  case success, failure
}

public struct SlackClient {
  let slackURL: String
  
  public init(slackURL: String) {
    self.slackURL = slackURL
  }
}

extension SlackClient {
  // TODO: Set the correct channel to send messages
  func failedTriggerPayload(planName: String, workflowId: String) -> [String: Any] {
    return [
      "channel": "#test-ci-alerts",
      "text": "*CI's attempt to trigger a build on Bitrise failed*",
      "attachments": [
        "title": "\(planName) ... attempted to trigger \(workflowId) on Bitrise",
        "color": "bad"
      ]
    ]
  }
  
  public func sendTriggerFailedMessageToSlack(planName: String, workflowId: String) -> StatusCode {
    let payload = failedTriggerPayload(planName: planName, workflowId: workflowId)
    
    if let endpoint = URL(string: slackURL) {
      var request = URLRequest(url: endpoint)
      request.httpMethod = "POST"
      
      let headers = ["Content-Type": "application/json"]
      request.allHTTPHeaderFields = headers
      
      var jsonData: Data
      do {
        jsonData = try JSONSerialization.data(withJSONObject: payload)
      } catch {
        print("Failed to serialize the slack payload")
        print(error)
        exit(1)
      }
      
      // ... and set our request's HTTP body
      request.httpBody = jsonData
      // print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
      
      let config = URLSessionConfiguration.default
      let session = URLSession(configuration: config)
      let (_, response, responseError) = session.synchronousDataTask(with: request)
      guard responseError == nil else {
        print(responseError!)
        exit(1)
      }
      
      if let res = response as? HTTPURLResponse, res.statusCode == 200 {
        // Below lines can be used for logging
        // print("response object: ", res)
        // print("Status code: ", res.statusCode)
        return .success
      } else {
        return .failure
      }
    } else {
      print(":!ERROR - incorrect URL to reach slack service.")
      return .failure
    }
  }

}
