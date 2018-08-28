import Foundation

protocol HttpRequestEngine {
    
    var url: String { get }
    var method: HttpMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    
    mutating func request() -> URLRequest
    
}
