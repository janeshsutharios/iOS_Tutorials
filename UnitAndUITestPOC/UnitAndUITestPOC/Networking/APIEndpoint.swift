//
//  APIEndpoint.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation

enum HTTPMethod: String, Sendable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIEndpoint: Sendable {
    case login(LoginRequest)
    case foodItems(String) // token
    
    var baseURL: String {
        return "http://localhost:3000"
    }
    
    var path: String {
        switch self {
        case .login:
            return "/login"
        case .foodItems:
            return "/food-items"
        }
    }
    
    var url: URL? {
        return URL(string: baseURL + path)
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .POST
        case .foodItems:
            return .GET
        }
    }
    
    // Make body return Data instead of Encodable to avoid Sendable issues
    var body: Data? {
        switch self {
        case .login(let request):
            return try? JSONEncoder().encode(request)
        case .foodItems:
            return nil
        }
    }
    
    var token: String? {
        switch self {
        case .login:
            return nil
        case .foodItems(let token):
            return token
        }
    }
    
//    var headers: [String: String] {
//        var headers = ["Content-Type": "application/json"]
//        
//        if let token = token {
//            headers["Authorization"] = "Bearer \(token)"
//        }
//        
//        return headers
//    }
//    
//    func urlRequest() throws -> URLRequest {
//        guard let url = url else {
//            throw URLError(.badURL)
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = method.rawValue
//        
//        // Set headers
//        headers.forEach { key, value in
//            request.setValue(value, forHTTPHeaderField: key)
//        }
//        
//        // Set body if needed - now using pre-encoded Data
//        if let body = body {
//            request.httpBody = body
//        }
//        
//        return request
//    }
}
