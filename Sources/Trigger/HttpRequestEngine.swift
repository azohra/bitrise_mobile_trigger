//
//  HttpRequestEngine.swift
//  MobileTriggerPackageDescription
//
//  Created by Azadeh Bagheri (LCL) on 8/27/18.
//

import Foundation

protocol HttpRequestEngine {
    
    var url: String { get }
    var method: HttpMethod { get }
    var headers: [String : String] { get }
    var body: Data? { get }
    
    mutating func generateHttpRequest() -> URLRequest
}

public struct RequestGenerator: HttpRequestEngine {
    
    var url: String
    var method: HttpMethod
    var headers: [String : String]
    var body: Data?
    
    func generateHttpRequest() -> URLRequest {
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
