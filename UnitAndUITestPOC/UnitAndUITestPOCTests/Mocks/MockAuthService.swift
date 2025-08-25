//
//  MockAuthService.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import Foundation
@testable import UnitAndUITestPOC

actor MockAuthService: AuthServiceProtocol {
    private var shouldSucceed = true
    private var mockResponse: LoginResponse?
    private var mockError: Error?
    private var loginCallCount = 0
    private var lastUsername: String?
    private var lastPassword: String?
    
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
    
    // MARK: - Test Helper Methods
    func setShouldSucceed(_ value: Bool) {
        shouldSucceed = value
    }
    
    func setMockResponse(_ response: LoginResponse) {
        mockResponse = response
    }
    
    func setMockError(_ error: Error) {
        mockError = error
    }
    
    func getLoginCallCount() -> Int {
        return loginCallCount
    }
    
    func getLastUsername() -> String? {
        return lastUsername
    }
    
    func getLastPassword() -> String? {
        return lastPassword
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
