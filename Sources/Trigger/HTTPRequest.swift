import Foundation
struct HTTPRequest: HttpRequestEngine {
    
    var url: String
    var method: HttpMethod
    var headers: [String: String]
    var body: Data?
    
    init(url: String, method: HttpMethod, headers: [String: String], body: Data? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
    
    mutating func request() -> URLRequest {
        // TODO: make a throwing function to make the error bubble up
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
