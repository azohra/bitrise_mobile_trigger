//
//  RequestEngine.swift
//  MobileTriggerPackageDescription
//
//  Created by Azadeh Bagheri (LCL) on 8/22/18.
//

import Foundation

public struct RequestEngine: BitriseClientDelegate {
    let url: String = ""
    let method: HttpMethod = .get
    let headers: [String : String] = ["": ""]
    let body: Data?
    
    mutating func generateHttpRequest() -> URLRequest {
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
