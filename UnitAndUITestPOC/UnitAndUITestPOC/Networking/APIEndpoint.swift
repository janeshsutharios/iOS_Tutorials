//
//  APIEndpoint.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIEndpoint {
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
    
    var body: Encodable? {
        switch self {
        case .login(let request):
            return request
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
}
