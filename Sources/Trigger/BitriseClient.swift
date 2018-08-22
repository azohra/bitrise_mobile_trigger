import Foundation

enum HttpMethod: String {
  case get = "GET"
  case post = "POST"
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
  private func bitrisePayload(branch: String, workflowId: String, envs: String?) throws -> Data {
    let hookInfo = HookInformation(type: "bitrise", apiToken: token)
    let buildParams = BuildParams(
        branch: branch,
        workflowID: workflowId,
        triggeredBy: "CI",
        environments: convertToEnvArray(from: envs)
        )
    let payload = BitrisePayload(apiInfo: hookInfo, params: buildParams)
    let encoder = JSONEncoder()
    let data = try encoder.encode(payload)
//    For logging
//    let _ = String(data: data, encoding: .utf8)!
    return data
  }
  
    private func convertToEnvArray(from envStr: String?) -> [[String: String]] {
    guard let envStr = envStr else { return [] }
    
      let envArray: [[String: String]] = envStr.components(separatedBy: ",").map {
        let arr = $0.components(separatedBy: ":")
        return ["mapped_to": "\(arr[0])", "value": "\(arr[1])", "is_expand": "true"]
      }
      return envArray
    }
  
  private func httpRequest(url: String, method: HttpMethod, headers: [String: String], body: Data?) -> URLRequest {
    guard let endpoint = URL(string: url) else {
      print(":!ERROR - \(url) could not be converted to proper URL")
      exit(1)
    }
    var request = URLRequest(url: endpoint)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = headers
    if let body = body { request.httpBody = body }
    return request
  }
  
  private func sendRequest(request: URLRequest) -> (Data?, URLResponse?) {
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    let (responseData, response, responseError) = session.synchronousDataTask(with: request)
    guard responseError == nil else {
      print(responseError!)
      exit(1)
    }
    
    return (responseData, response)
  }
}

extension BitriseClient {
  public func triggerWorkflow(branch: String, workflowId: String, envs: String?) -> BitriseTriggerResponse? {
    // create the payload for the http call
    var payload: Data
    do {
      payload = try bitrisePayload(branch: branch, workflowId: workflowId, envs: envs)
    } catch {
      print(":!ERROR - ", error)
      exit(1)
    }
    
    // build request
    let request = httpRequest(
        url: triggerEndpoint,
        method: .post,
        headers: ["Content-Type": "application/json"],
        body: payload)
    
    // send request => (responseData, response)
    let (responseData, _) = sendRequest(request: request)
    
    // TODO: log response
    
    // APIs usually respond with the data you just sent in your POST request
    guard let data = responseData, String(data: data, encoding: .utf8) != nil else {
      print("no readable data received in response")
      return nil
    }
    
    do {
      let decoder = JSONDecoder()
      let res = try decoder.decode(BitriseTriggerResponse.self, from: data)
      return res
    } catch {
      print(error)
      return nil
    }
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
      if let data = responseData, String(data: data, encoding: .utf8) != nil {
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
      print(":!ERROR - Cannot convert the URL string to a URL object")
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
      if let data = responseData, String(data: data, encoding: .utf8) != nil {
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
  // See http://devcenter.bitrise.io/api/v0.1/#get-appsapp-slugbuildsbuild-sluglog
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
