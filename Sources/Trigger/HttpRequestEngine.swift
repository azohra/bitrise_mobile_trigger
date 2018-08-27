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
