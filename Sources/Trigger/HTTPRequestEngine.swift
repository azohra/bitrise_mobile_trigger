import Foundation

protocol HTTPRequestEngine {
    
    var url: String { get }
    var method: HttpMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    
    func request() -> URLRequest
    func sendRequest(request: URLRequest) -> (Data?, URLResponse?, Error?)
}
