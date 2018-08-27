import Foundation
struct HTTPRequest: HttpRequestEngine {
    
    var url: String
    var method: HttpMethod
    var headers: [String : String]
    var body: Data? = nil
    
    mutating func generateRequest() -> URLRequest {
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
}
