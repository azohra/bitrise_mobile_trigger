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
