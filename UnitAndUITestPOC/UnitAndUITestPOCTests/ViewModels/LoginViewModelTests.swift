//
//  LoginViewModelTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

@MainActor
final class LoginViewModelTests: XCTestCase {
    var mockAuthService: MockAuthService!
    var viewModel: LoginViewModel!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        viewModel = LoginViewModel(authService: mockAuthService)
    }
    
    override func tearDown() {
        mockAuthService.reset()
        mockAuthService = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Given & When & Then
        XCTAssertEqual(viewModel.username, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertEqual(viewModel.authState, .idle)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.accessToken, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoginSuccess() async {
        // Given
        let expectedResponse = LoginResponse(
            accessToken: "test-access-token",
            refreshToken: "test-refresh-token"
        )
        mockAuthService.mockResponse = expectedResponse
        viewModel.username = "testuser"
        viewModel.password = "testpass"
        
        // When
        await viewModel.login()
        
        // Then
        XCTAssertEqual(viewModel.authState, .authenticated)
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.accessToken, "test-access-token")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockAuthService.loginCallCount, 1)
        XCTAssertEqual(mockAuthService.lastUsername, "testuser")
        XCTAssertEqual(mockAuthService.lastPassword, "testpass")
    }
    
    func testLoginFailure() async {
        // Given
        mockAuthService.shouldSucceed = false
        mockAuthService.mockError = NetworkError.unauthorized
        viewModel.username = "testuser"
        viewModel.password = "testpass"
        
        // When
        await viewModel.login()
        
        // Then
        if case .error(let message) = viewModel.authState {
            XCTAssertEqual(message, "Unauthorized access")
        } else {
            XCTFail("Expected error state")
        }
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.accessToken, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "Unauthorized access")
    }
    
    func testLoginWithEmptyCredentials() async {
        // Given
        viewModel.username = ""
        viewModel.password = ""
        
        // When
        await viewModel.login()
        
        // Then
        if case .error(let message) = viewModel.authState {
            XCTAssertEqual(message, "Please enter both username and password")
        } else {
            XCTFail("Expected error state")
        }
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertEqual(mockAuthService.loginCallCount, 0)
    }
    
    func testLoginWithEmptyUsername() async {
        // Given
        viewModel.username = ""
        viewModel.password = "testpass"
        
        // When
        await viewModel.login()
        
        // Then
        if case .error(let message) = viewModel.authState {
            XCTAssertEqual(message, "Please enter both username and password")
        } else {
            XCTFail("Expected error state")
        }
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertEqual(mockAuthService.loginCallCount, 0)
    }
    
    func testLoginWithEmptyPassword() async {
        // Given
        viewModel.username = "testuser"
        viewModel.password = ""
        
        // When
        await viewModel.login()
        
        // Then
        if case .error(let message) = viewModel.authState {
            XCTAssertEqual(message, "Please enter both username and password")
        } else {
            XCTFail("Expected error state")
        }
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertEqual(mockAuthService.loginCallCount, 0)
    }
    
    func testLoginLoadingState() async {
        // Given
        viewModel.username = "testuser"
        viewModel.password = "testpass"
        
        // Create a task that will delay the response
        let expectation = XCTestExpectation(description: "Login completion")
        
        // When
        Task {
            await viewModel.login()
            expectation.fulfill()
        }
        
        // Check loading state immediately after starting
        XCTAssertEqual(viewModel.authState, .loading)
        XCTAssertTrue(viewModel.isLoading)
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func testResetState() {
        // Given
        viewModel.username = "testuser"
        viewModel.password = "testpass"
        viewModel.authState = .error("test error")
        
        // When
        viewModel.resetState()
        
        // Then
        XCTAssertEqual(viewModel.username, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertEqual(viewModel.authState, .idle)
    }
    
    func testIsLoadingComputedProperty() {
        // Given & When & Then
        viewModel.authState = .idle
        XCTAssertFalse(viewModel.isLoading)
        
        viewModel.authState = .loading
        XCTAssertTrue(viewModel.isLoading)
        
        viewModel.authState = .authenticated
        XCTAssertFalse(viewModel.isLoading)
        
        viewModel.authState = .error("test")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testErrorMessageComputedProperty() {
        // Given & When & Then
        viewModel.authState = .idle
        XCTAssertNil(viewModel.errorMessage)
        
        viewModel.authState = .loading
        XCTAssertNil(viewModel.errorMessage)
        
        viewModel.authState = .authenticated
        XCTAssertNil(viewModel.errorMessage)
        
        viewModel.authState = .error("test error")
        XCTAssertEqual(viewModel.errorMessage, "test error")
    }
}
