//
//  MockNetworkService.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation
@testable import UnitAndUITestPOC

actor MockNetworkService: NetworkServiceProtocol {
    private var shouldSucceed = true
    private var mockResponse: Any?
    private var mockError: NetworkError?
    private var requestCallCount = 0
    private var lastEndpoint: APIEndpoint?
    
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
    
    // MARK: - Test Helper Methods
    func setShouldSucceed(_ value: Bool) {
        shouldSucceed = value
    }
    
    func setMockResponse(_ response: Any) {
        mockResponse = response
    }
    
    func setMockError(_ error: NetworkError) {
        mockError = error
    }
    
    func getRequestCallCount() -> Int {
        return requestCallCount
    }
    
    func getLastEndpoint() -> APIEndpoint? {
        return lastEndpoint
    }
    
    func reset() {
        shouldSucceed = true
        mockResponse = nil
        mockError = nil
        requestCallCount = 0
        lastEndpoint = nil
    }
}
