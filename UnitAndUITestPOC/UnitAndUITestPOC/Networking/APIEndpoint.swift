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

enum APIEndpoint: Sendable, Codable {
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
    
    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var allKeys = ArraySlice(container.allKeys)
        guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
            throw DecodingError.typeMismatch(APIEndpoint.self, DecodingError.Context.init(codingPath: container.codingPath, debugDescription: "Invalid number of keys found, expected one.", underlyingError: nil))
        }
        switch onlyKey {
        case .login:
            let nestedContainer = try container.nestedContainer(keyedBy: APIEndpoint.LoginCodingKeys.self, forKey: .login)
            self = APIEndpoint.login(try nestedContainer.decode(LoginRequest.self, forKey: APIEndpoint.LoginCodingKeys._0))
        case .foodItems:
            let nestedContainer = try container.nestedContainer(keyedBy: APIEndpoint.FoodItemsCodingKeys.self, forKey: .foodItems)
            self = APIEndpoint.foodItems(try nestedContainer.decode(String.self, forKey: APIEndpoint.FoodItemsCodingKeys._0))
        }
    }
}
