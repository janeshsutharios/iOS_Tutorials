//
//  MockNetworkService.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation
@testable import UnitAndUITestPOC

class MockNetworkService: NetworkServiceProtocol {
    var shouldSucceed = true
    var mockResponse: Any?
    var mockError: NetworkError?
    var requestCallCount = 0
    var lastEndpoint: APIEndpoint?
    
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        requestCallCount += 1
        lastEndpoint = endpoint
        
        if !shouldSucceed {
            if let mockError = mockError {
                throw mockError
            } else {
                throw NetworkError.unknown
            }
        }
        
        if let mockResponse = mockResponse as? T {
            return mockResponse
        }
        
        throw NetworkError.decodingError
    }
    
    func reset() {
        shouldSucceed = true
        mockResponse = nil
        mockError = nil
        requestCallCount = 0
        lastEndpoint = nil
    }
}
