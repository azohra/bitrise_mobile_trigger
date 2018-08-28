import Foundation
struct HTTPRequest: HTTPRequestEngine {
    
    var url: String
    var method: HttpMethod
    var headers: [String: String]
    var body: Data?
    
    init(url: String, method: HttpMethod, headers: [String: String] = [:], body: Data? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
    
     func request() -> URLRequest {
        // TODO: make this a throwing function to make the error bubble up
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
    
    func sendRequest(request: URLRequest) -> (Data?, URLResponse?, Error? ) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let (responseData, response, responseError) = session.synchronousDataTask(with: request)
        guard responseError == nil else {
            print(responseError!)
            exit(1)
        }
        
        return (responseData, response, responseError)
    }
}
