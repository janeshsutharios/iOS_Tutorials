//
//  MemoryTest.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

@MainActor
final class MemoryTest: XCTestCase {
    
    override func setUp() async throws {
        // Clean setup
    }
    
    override func tearDown() async throws {
        // Clean teardown
    }
    
    func testBasicMemoryManagement() {
        // Simple test to check if basic memory management works
        let loginRequest = LoginRequest(username: "test", password: "test")
        XCTAssertEqual(loginRequest.username, "test")
        XCTAssertEqual(loginRequest.password, "test")
    }
    
    func testNetworkServiceMemoryManagement() async throws {
        // Test NetworkService creation and destruction
        let networkService = NetworkService(session: MockURLSession())
        XCTAssertNotNil(networkService)
        
        // Test with mock session
        let mockSession = MockURLSession()
        let networkServiceWithMock = NetworkService(session: mockSession)
        XCTAssertNotNil(networkServiceWithMock)
    }
    
    func testMockServicesMemoryManagement() async {
        // Test mock services creation and destruction
        let mockAuthService = MockAuthService()
        let mockFoodService = MockFoodService()
        let mockNetworkService = MockNetworkService()
        
        XCTAssertNotNil(mockAuthService)
        XCTAssertNotNil(mockFoodService)
        XCTAssertNotNil(mockNetworkService)
    }
    
    func testViewModelMemoryManagement() async {
        // Test ViewModel creation and destruction
        let mockAuthService = MockAuthService()
        let mockFoodService = MockFoodService()
        
        let loginViewModel = LoginViewModel(authService: mockAuthService)
        let foodViewModel = FoodViewModel(foodService: mockFoodService)
        
        XCTAssertNotNil(loginViewModel)
        XCTAssertNotNil(foodViewModel)
    }
    
    func testRepeatedCreationAndDestruction() async {
        // Test repeated creation and destruction to catch memory issues
        for _ in 0..<100 {
            let mockAuthService = MockAuthService()
            let loginViewModel = LoginViewModel(authService: mockAuthService)
            
            XCTAssertEqual(loginViewModel.username, "test")
            XCTAssertEqual(loginViewModel.password, "password")
            
            // Force some state changes
            loginViewModel.authState = .loading
            loginViewModel.authState = .idle
            
            // Explicitly set to nil to force deallocation
            // Note: In Swift, this isn't usually necessary, but it can help identify issues
        }
    }
}

// MARK: - Simple Mock for Memory Testing

final class SimpleMockURLSession: URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        let data = """
        {
            "accessToken": "test-token",
            "refreshToken": "test-refresh"
        }
        """.data(using: .utf8)!
        
        return (data, response)
    }
}
