import Foundation
#if os(Linux)
import Glibc
#endif

public struct Config: Codable {
    let theAccessToken: String
    let token: String
    let slug: String
    let projectName: String
    public let slackURL: String?

    public init(with jsonData: Data) throws {
      let decoder = JSONDecoder()
      self = try decoder.decode(Config.self, from: jsonData)
    }
}

extension Config {
  public enum FileError: Error {
    case fileNotFound(String)
  }
  
  public static func readConfigFile(path: String) throws -> Data {
    guard let fileHandle = FileHandle(forReadingAtPath: path) else {
      let errorMessage = "Could not find config.json file at location: \(path)."
      throw FileError.fileNotFound(errorMessage)
    }
    
    let data = fileHandle.readDataToEndOfFile()
    fileHandle.closeFile()
    return data
  }
}
