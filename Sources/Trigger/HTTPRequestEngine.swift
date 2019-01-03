import Foundation

protocol HTTPRequestEngine {
    
    func request(url: String, method: HttpMethod, headers: [String: String]?, body: Data?) -> URLRequest
    func sendRequest(request: URLRequest) -> (Data?, URLResponse?, Error?)
}
