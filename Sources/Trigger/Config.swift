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

    public init(with configFilePath: String) {
        let data: Data
        if let fileHandle = FileHandle(forReadingAtPath: configFilePath) {
            data = fileHandle.readDataToEndOfFile()
            fileHandle.closeFile()
        } else {
            print("""
              Could not find config.json file at location: \(configFilePath).
              Please check config file location path.
            """)
            exit(1)
        }
        
        do {
            let decoder = JSONDecoder()
            self = try decoder.decode(Config.self, from: data)
        } catch {
            print(error)
            exit(1)
        }
    }
}
