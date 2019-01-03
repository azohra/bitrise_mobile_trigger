import Foundation

struct BitrisePayload: Codable {
  let apiInfo: HookInformation
  let params: BuildParams

    enum CodingKeys: String, CodingKey {
      case apiInfo = "hook_info"
      case params = "build_params"
    }
}

struct HookInformation: Codable {
    let type: String
    let apiToken: String
    
    enum CodingKeys: String, CodingKey {
      case type
      case apiToken = "api_token"
    }
}

struct BuildParams: Codable {
    let branch: String
    let workflowID: String
    let triggeredBy: String
    let environments: [[String: String]]
    
    enum CodingKeys: String, CodingKey {
      case branch, environments
      case workflowID = "workflow_id"
      case triggeredBy = "triggered_by"
    }
}
