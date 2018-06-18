import Foundation

public struct BitriseBuildResponse: Codable {
  public let data: BuildData
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
