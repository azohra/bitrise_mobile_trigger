import Foundation
struct HTTPRequest: HTTPRequestEngine {

    func request(url: String, method: HttpMethod, headers: [String: String]?, body: Data?) -> URLRequest {
        // TODO: make this a throwing function to make the error bubble up
        guard let endpoint = URL(string: url) else {
            print(":!ERROR - \(url) could not be converted to proper URL")
            exit(1)
        }
        var request = URLRequest(url: endpoint)
        request.httpMethod = method.rawValue
        if let headers = headers { request.allHTTPHeaderFields = headers }
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
