import Foundation

public struct BitriseTriggerResponse: Codable {
  public let status: String
  public let message: String
  public let slug: String
  public let service: String
  public let buildSlug: String
  public let buildNumber: Int
  public let buildURL: String
  public let triggeredWorkflow: String
  
  enum CodingKeys: String, CodingKey {
    case status, message, slug, service
    case buildSlug = "build_slug"
    case buildNumber = "build_number"
    case buildURL = "build_url"
    case triggeredWorkflow = "triggered_workflow"
  }
}

public struct BuildParam: Codable {
  let workflowId: String
  let branch: String
  
  enum CodingKeys: String, CodingKey {
    case branch
    case workflowId = "workflow_id"
  }
}

public struct BuildData: Codable {
  public let triggeredAt: String
  public let startedOnWorkerAt: String?
  // public let environment_prepare_finished_at: String
  // public let finished_at: String
  public let slug: String
  public let status: Int
  public let statusText: String
  // public let abort_reason: String
  public let isOnHold: Bool
  public let branch: String
  public let buildNumber: Int
  // public let commit_hash: String
  // public let commit_message: String
  // public let tag: String
  public let triggeredWorkflow: String
  // public let triggered_by: String
  // public let stack_config_type: String
  public let stackIdentifier: String
  // public let original_build_params: [String:String]
  
  enum CodingKeys: String, CodingKey {
    case status, branch, slug
    case buildNumber = "build_number"
    case triggeredAt = "triggered_at"
    case startedOnWorkerAt = "started_on_worker_at"
    case statusText = "status_text"
    case triggeredWorkflow = "triggered_workflow"
    case stackIdentifier = "stack_identifier"
    case isOnHold = "is_on_hold"
  }
}

public struct BitriseBuildResponse: Codable {
  public let data: BuildData
}

public struct BitriseLogInfoResponse: Codable {
  public let isArchived: Bool
  public let expiringRawLogURL: String?
  
  enum CodingKeys: String, CodingKey {
    case isArchived = "is_archived"
    case expiringRawLogURL = "expiring_raw_log_url"
  }
}

public struct BitriseClient {
  let theAccessToken: String
  let token: String
  let slug: String
  let triggerEndpoint: String
  
  public init(projectConfig: Config) {
    self.theAccessToken = projectConfig.theAccessToken
    self.token = projectConfig.token
    self.slug = projectConfig.slug
    self.triggerEndpoint = "https://app.bitrise.io/app/\(slug)/build/start.json"
  }
}

extension BitriseClient {
  private func bitrisePayload(branch: String, workflowId: String) -> [String: [String: String]] {
    return [
      "hook_info": ["type": "bitrise", "api_token": token],
      "build_params": ["branch": branch, "workflow_id": workflowId, "triggered_by": "CI"]
    ]
  }
}

extension BitriseClient {
  public func triggerWorkflow(branch: String, workflowId: String) -> BitriseTriggerResponse? {
    let payload = bitrisePayload(branch: branch, workflowId: workflowId)
    if let endpoint = URL(string: triggerEndpoint) {
      var request = URLRequest(url: endpoint)
      request.httpMethod = "POST"
      
      let headers = ["Content-Type": "application/json"]
      request.allHTTPHeaderFields = headers
      
      let encoder = JSONEncoder()
      let jsonData = try? encoder.encode(payload)
      
      // ... and set our request's HTTP body
      request.httpBody = jsonData
      // print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
      
      let config = URLSessionConfiguration.default
      let session = URLSession(configuration: config)
      let (responseData, response, responseError) = session.synchronousDataTask(with: request)
      guard responseError == nil else {
        print(responseError!)
        exit(1)
      }
      
      //TODO: make use to the response
      // print(response ?? "response returned nil")
      
      // APIs usually respond with the data you just sent in your POST request
      if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
        // For logging
        // print("response: ", utf8Representation)
        do {
          let decoder = JSONDecoder()
          let res = try decoder.decode(BitriseTriggerResponse.self, from: data)
          return res
        } catch {
          print(error)
          return nil
        }
      } else {
        print("no readable data received in response")
      }
    }
    return nil
  }
  
  // Documented at: https://devcenter.bitrise.io/api/v0.1/#get-appsapp-slugbuildsbuild-slug
  public func checkBuildStatus(slug buildSlug: String) -> BitriseBuildResponse? {
    if let endpoint = URL(string: "https://api.bitrise.io/v0.1/apps/\(slug)/builds/\(buildSlug)") {
      var request = URLRequest(url: endpoint)
      request.httpMethod = "GET"
      
      let headers = ["Content-Type": "application/json", "Authorization": theAccessToken]
      request.allHTTPHeaderFields = headers
      
      let config = URLSessionConfiguration.default
      let session = URLSession(configuration: config)
      let (responseData, response, responseError) = session.synchronousDataTask(with: request)
      
      // TODO: CHeck guard statement
      guard responseError == nil else {
        print(responseError!)
        exit(1)
      }
      
      if let res = response as? HTTPURLResponse {
        let returnCode = res.statusCode
        if returnCode != 200 { print("Response code for checkBuildStatus was ", returnCode) }
      } else {
        print("response returned nil")
      }
      
      // APIs usually respond with the data you just sent in your GET request
      if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
        // For logging
        // print("response: ", utf8Representation)
        
        do {
          let decoder = JSONDecoder()
          let res = try decoder.decode(BitriseBuildResponse.self, from: data)
          return res
        } catch {
          print(error)
          return nil
        }
      } else {
        print("no readable data received in response")
        return nil
      }
      
    } else {
      print(":!ERROR - incorrect URL to reach Bitrise service.")
      return nil
    }
  }
  
  // Documented at http://devcenter.bitrise.io/api/v0.1/#get-appsapp-slugbuildsbuild-sluglog
  public func getLogInfo(slug buildSlug: String) -> BitriseLogInfoResponse? {
    if let endpoint = URL(string: "https://api.bitrise.io/v0.1/apps/\(slug)/builds/\(buildSlug)/log") {
      var request = URLRequest(url: endpoint)
      request.httpMethod = "GET"
      
      let headers = ["Content-Type": "application/json", "Authorization": theAccessToken]
      request.allHTTPHeaderFields = headers
      
      let config = URLSessionConfiguration.default
      let session = URLSession(configuration: config)
      let (responseData, response, responseError) = session.synchronousDataTask(with: request)
      
      // TODO: CHeck guard statement
      guard responseError == nil else {
        print(responseError!)
        exit(1)
      }
      
      if let res = response as? HTTPURLResponse {
        let returnCode = res.statusCode
        if returnCode != 200 { print("Response code from `get log info` endpoint was ", returnCode) }
      } else {
        print("response returned nil")
      }
      
      // APIs usually respond with the data you just sent in your GET request
      if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
        // For logging
        // print("response: ", utf8Representation)
        
        do {
          let decoder = JSONDecoder()
          let res = try decoder.decode(BitriseLogInfoResponse.self, from: data)
          return res
        } catch {
          print(error)
          return nil
        }
      } else {
        print("no readable data received in response")
        return nil
      }
      
    } else {
      print(":!ERROR - incorrect URL to reach Bitrise service.")
      return nil
    }
  }
  
  // No special headers should be added for the request to the expiring_raw_log_url.
  //See http://devcenter.bitrise.io/api/v0.1/#get-appsapp-slugbuildsbuild-sluglog
  public func getLogs(from logInfo: BitriseLogInfoResponse) -> String? {
    if let url = logInfo.expiringRawLogURL {
      if let endpoint = URL(string: url) {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let (responseData, response, responseError) = session.synchronousDataTask(with: request)
        
        // TODO: CHeck guard statement
        guard responseError == nil else {
          print(responseError!)
          exit(1)
        }
        
        if let res = response as? HTTPURLResponse {
          let returnCode = res.statusCode
          if returnCode != 200 { print("Response code from GET request to raw log url endpoint was ", returnCode) }
        } else {
          print("response returned nil")
        }
        
        // APIs usually respond with the data you just sent in your GET request
        if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
          return utf8Representation
        } else {
          print("no readable data received in response")
          return nil
        }
      } else {
        print(":!ERROR - incorrect URL to reach Bitrise service.")
        return nil
      }
      
    } else {
      return ":!ERROR - Could not get the expiring raw log url!"
    }
  }
  
  // # Status codes (status) and related status texts (status_text):
  // # status=0: Not finished yet.
  // # If is_on_hold = true: the build did not start yet (status_text=on-hold)
  // # If is_on_hold = false: the build is running (status_text=in-progress).
  // # status=1: Build finished, with success (status_text=success).
  // # status=2: Build finished, with error (status_text=error).
  // # status=3: Build was aborted (status_text=aborted).
  public  func buildStatusMessage(_ status: Int) -> String {
    switch status {
    case 0:  return "Build TIMED OUT base on mobile trigger internal setting"
    case 1:  return "Build finished, with success"
    case 2:  return "Build finished, with error"
    case 3:  return "Build was aborted"
    default: return "Build status did not match any of the values 0, 1, 2 or 3.\n This is very strange!"
    }
  }
}

// MARK: Mock Client for testing
// Could not get the DEBUG flag to work when
// testing from the command line, i.e. `swift test`
// #if DEBUG
extension BitriseClient {
  public init() {
    self.theAccessToken = "dummy_theAccessToken"
    self.token = "dummy_api_token"
    self.slug = "fake_slug_4243534"
    self.triggerEndpoint = "https://dummy.app.bitrise.io/app/\(slug)/build/start.json"
  }
}
// #endif
