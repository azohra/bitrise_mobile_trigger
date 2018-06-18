import Foundation

public struct BitriseLogInfoResponse: Codable {
  public let isArchived: Bool
  public let expiringRawLogURL: String?
  
  enum CodingKeys: String, CodingKey {
    case isArchived = "is_archived"
    case expiringRawLogURL = "expiring_raw_log_url"
  }
}
