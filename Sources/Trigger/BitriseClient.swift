import Foundation

enum HttpMethod: String {
  case get = "GET"
  case post = "POST"
}
enum TriggerError: Error {
    case badKeyValueFormat
}
public struct BitriseClient {
  let delegate: HTTPRequestEngine
  let theAccessToken: String
  let token: String
  let slug: String
  
  public init(projectConfig: Config) {
    self.theAccessToken = projectConfig.theAccessToken
    self.token = projectConfig.token
    self.slug = projectConfig.slug
    self.delegate = HTTPRequest()
  }
}

extension BitriseClient {
  private func bitrisePayload(branch: String, workflowId: String, envs: String?) throws -> Data {
    let hookInfo = HookInformation(type: "bitrise", apiToken: token)
    let buildParams = BuildParams(
        branch: branch,
        workflowID: workflowId,
        triggeredBy: "CI",
        environments: try convertToEnvArray(from: envs)
        )
    let payload = BitrisePayload(apiInfo: hookInfo, params: buildParams)
    let encoder = JSONEncoder()
    let data = try encoder.encode(payload)
//    For logging
//    let _ = String(data: data, encoding: .utf8)!
    return data
  }
  
  private func convertToEnvArray(from envStr: String?) throws -> [[String: String]] {
    guard let envStr = envStr else { return [] }
    let envArray: [[String: String]] = try envStr.components(separatedBy: ",").map {
        let arr = $0.components(separatedBy: "=")
        if arr.count < 2 { throw TriggerError.badKeyValueFormat }
      return ["mapped_to": "\(arr[0])", "value": "\(arr[1])", "is_expand": "true"]
    }
    return envArray
  }
}

extension BitriseClient {
  public func triggerWorkflow(branch: String, workflowId: String, envs: String?) -> BitriseTriggerResponse? {
    let triggerEndpoint = "https://app.bitrise.io/app/\(slug)/build/start.json"
    
    // create the payload for the http call
    
    var payload: Data
    do {
      payload = try bitrisePayload(branch: branch, workflowId: workflowId, envs: envs)
    } catch {
      print(":!ERROR - ", error)
      exit(1)
    }
    
    // build the request
    
    let request = delegate.request(
        url: triggerEndpoint,
        method: .post,
        headers: ["Content-Type": "application/json"],
        body: payload)
    
    // send the request
    
    let (responseData, _, responseError) = delegate.sendRequest(request: request)
    
    guard responseError == nil else {
        print(responseError!)
        exit(1)
    }
    
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
    let endpoint = "https://api.bitrise.io/v0.1/apps/\(slug)/builds/\(buildSlug)"
    let headers = ["Content-Type": "application/json", "Authorization": theAccessToken]
    
    let request = delegate.request(url: endpoint, method: .get, headers: headers, body: nil)
    let (responseData, response, responseError) = delegate.sendRequest(request: request)
    
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
    guard let data = responseData, String(data: data, encoding: .utf8) != nil else {
      print("no readable data received in response")
      return nil
    }
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
  }
  
  // Documented at http://devcenter.bitrise.io/api/v0.1/#get-appsapp-slugbuildsbuild-sluglog
    public func getLogInfo(slug buildSlug: String) -> BitriseLogInfoResponse? {
      let endpoint = "https://api.bitrise.io/v0.1/apps/\(slug)/builds/\(buildSlug)/log"
      let headers = ["Content-Type": "application/json", "Authorization": theAccessToken]
        
      let request = delegate.request(url: endpoint, method: .get, headers: headers, body: nil)
      let (responseData, response, responseError) = delegate.sendRequest(request: request)
      
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
      guard let data = responseData, String(data: data, encoding: .utf8) != nil else {
        print("no readable data received in response")
        return nil
      }
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
  }
  
  // No special headers should be added for the request to the expiring_raw_log_url.
  // See http://devcenter.bitrise.io/api/v0.1/#get-appsapp-slugbuildsbuild-sluglog
  public func getLogs(from logInfo: BitriseLogInfoResponse) -> String? {
    guard let url = logInfo.expiringRawLogURL else {
      print(":!ERROR - Could not get the expiring raw log url!")
      exit(1)
    }
    let request = delegate.request(url: url, method: .get, headers: nil, body: nil)
    let (responseData, response, responseError) = delegate.sendRequest(request: request)
        
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
    self.delegate = HTTPRequest()
  }

}
// #endif
