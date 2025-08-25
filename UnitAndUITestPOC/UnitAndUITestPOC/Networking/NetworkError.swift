//
//  NetworkError.swift
//  UnitAndUITestPOC
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation

enum NetworkError: LocalizedError, Equatable, Sendable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
    
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkError(Error)
    case unauthorized
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
