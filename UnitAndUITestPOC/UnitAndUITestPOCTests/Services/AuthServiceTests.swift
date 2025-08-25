//
//  AuthServiceTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

final class AuthServiceTests: XCTestCase {
    var mockNetworkService: MockNetworkService!
    var authService: AuthService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        authService = AuthService(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        mockNetworkService.reset()
        mockNetworkService = nil
        authService = nil
        super.tearDown()
    }
    
    func testLoginSuccess() async throws {
        // Given
        let expectedResponse = LoginResponse(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token"
        )
        mockNetworkService.mockResponse = expectedResponse
        
        // When
        let result = try await authService.login(username: "testuser", password: "testpass")
        
        // Then
        XCTAssertEqual(result.accessToken, "test-access-token")
        XCTAssertEqual(result.refreshToken, "test-refresh-token")
        XCTAssertEqual(mockNetworkService.requestCallCount, 1)
        
        // Verify the endpoint was called correctly
        if case .login(let request) = mockNetworkService.lastEndpoint {
            XCTAssertEqual(request.username, "testuser")
            XCTAssertEqual(request.password, "testpass")
        } else {
            XCTFail("Expected login endpoint to be called")
        }
    }
    
    func testLoginFailure() async {
        // Given
        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = NetworkError.unauthorized
        
        // When & Then
        do {
            _ = try await authService.login(username: "testuser", password: "testpass")
            XCTFail("Expected login to fail")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.unauthorized)
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
    
    func testLoginWithNetworkError() async {
        // Given
        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = NetworkError.serverError(500)
        
        // When & Then
        do {
            _ = try await authService.login(username: "testuser", password: "testpass")
            XCTFail("Expected login to fail")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.serverError(500))
        } catch {
            XCTFail("Expected NetworkError but got \(error)")
        }
    }
}
