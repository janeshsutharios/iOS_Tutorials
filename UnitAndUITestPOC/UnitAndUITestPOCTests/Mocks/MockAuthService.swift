//
//  MockAuthService.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation
@testable import UnitAndUITestPOC

actor MockAuthService: AuthServiceProtocol {
    var shouldSucceed = true
    var mockResponse: LoginResponse?
    var mockError: Error?
    var loginCallCount = 0
    var lastUsername: String?
    var lastPassword: String?
    
    func login(username: String, password: String) async throws -> LoginResponse {
        loginCallCount += 1
        lastUsername = username
        lastPassword = password
        
        if !shouldSucceed {
            if let mockError = mockError {
                throw mockError
            } else {
                throw NetworkError.unknown
            }
        }
        
        if let mockResponse = mockResponse {
            return mockResponse
        }
        
        // Default success response
        return LoginResponse(
            accessToken: "mock-access-token",
            refreshToken: "mock-refresh-token"
        )
    }
    
    func reset() {
        shouldSucceed = true
        mockResponse = nil
        mockError = nil
        loginCallCount = 0
        lastUsername = nil
        lastPassword = nil
    }
}
