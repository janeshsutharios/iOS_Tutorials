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
    
    // MARK: - Network Service
    
    func testNetworkServiceDeallocation() async throws {
        weak var weakNetworkService: NetworkService?
        
        do {
            let mockSession = MockURLSession()
            let service = NetworkService(session: mockSession)
            weakNetworkService = service
            XCTAssertNotNil(weakNetworkService)
        }
        
        // service should deallocate after scope
        XCTAssertNil(weakNetworkService, "❌ NetworkService leaked memory")
    }
    
    // MARK: - Mock Services
    
    func testMockServicesDeallocation() async {
        weak var weakAuthService: MockAuthService?
        weak var weakFoodService: MockFoodService?
        weak var weakNetworkService: MockNetworkService?
        
        do {
            let authService = MockAuthService()
            let foodService = MockFoodService()
            let networkService = MockNetworkService()
            
            weakAuthService = authService
            weakFoodService = foodService
            weakNetworkService = networkService
            
            XCTAssertNotNil(weakAuthService)
            XCTAssertNotNil(weakFoodService)
            XCTAssertNotNil(weakNetworkService)
        }
        
        XCTAssertNil(weakAuthService, "❌ MockAuthService leaked memory")
        XCTAssertNil(weakFoodService, "❌ MockFoodService leaked memory")
        XCTAssertNil(weakNetworkService, "❌ MockNetworkService leaked memory")
    }
    
    // MARK: - ViewModels
    
    func testViewModelDeallocation() async {
        weak var weakLoginVM: LoginViewModel?
        weak var weakFoodVM: FoodViewModel?
        
        do {
            let authService = MockAuthService()
            let foodService = MockFoodService()
            
            let loginVM = LoginViewModel(authService: authService)
            let foodVM = FoodViewModel(foodService: foodService)
            
            weakLoginVM = loginVM
            weakFoodVM = foodVM
            
            XCTAssertNotNil(weakLoginVM)
            XCTAssertNotNil(weakFoodVM)
        }
        
        XCTAssertNil(weakLoginVM, "❌ LoginViewModel leaked memory")
        XCTAssertNil(weakFoodVM, "❌ FoodViewModel leaked memory")
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
