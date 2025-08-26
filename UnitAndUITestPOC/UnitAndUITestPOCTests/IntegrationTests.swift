//
//  IntegrationTests.swift
//  UnitAndUITestPOCTests
//
//  Created by Janesh Suthar on 25/08/25.
//

import XCTest
@testable import UnitAndUITestPOC

@MainActor
final class IntegrationTests: XCTestCase {
    
    // MARK: - Login Flow Integration Tests
    
    func testCompleteLoginFlowSuccess() async throws {
        // Setup mock network service with successful response
        let mockData = """
        {
            "accessToken": "integration-test-token",
            "refreshToken": "integration-refresh-token"
        }
        """.data(using: .utf8)!
        
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/login")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        let mockSession = MockURLSession()
        mockSession.mockData = mockData
        mockSession.mockResponse = mockResponse
        
        // Create real services with mock network
        let networkService = NetworkService(session: mockSession)
        let authService = AuthService(networkService: networkService)
        let loginViewModel = LoginViewModel(authService: authService)
        
        // Set credentials
        loginViewModel.username = "integrationuser"
        loginViewModel.password = "integrationpass"
        
        // Perform login
        await loginViewModel.login()
        
        // Verify complete flow
        XCTAssertEqual(loginViewModel.authState, .authenticated)
        XCTAssertTrue(loginViewModel.isAuthenticated)
        XCTAssertEqual(loginViewModel.accessToken, "integration-test-token")
    }
    
    func testCompleteLoginFlowWithServerError() async {
        // Setup mock network service with server error
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/login")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = mockResponse
        
        // Create real services with mock network
        let networkService = NetworkService(session: mockSession)
        let authService = AuthService(networkService: networkService)
        let loginViewModel = LoginViewModel(authService: authService)
        
        // Set credentials
        loginViewModel.username = "integrationuser"
        loginViewModel.password = "integrationpass"
        
        // Perform login
        await loginViewModel.login()
        
        // Verify error handling
        XCTAssertEqual(loginViewModel.authState, .error("Server error with code: 500"))
        XCTAssertFalse(loginViewModel.isAuthenticated)
        XCTAssertTrue(loginViewModel.accessToken.isEmpty)
    }
    
    func testCompleteLoginFlowWithUnauthorizedError() async {
        // Setup mock network service with unauthorized error
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/login")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = mockResponse
        
        // Create real services with mock network
        let networkService = NetworkService(session: mockSession)
        let authService = AuthService(networkService: networkService)
        let loginViewModel = LoginViewModel(authService: authService)
        
        // Set credentials
        loginViewModel.username = "integrationuser"
        loginViewModel.password = "wrongpass"
        
        // Perform login
        await loginViewModel.login()
        
        // Verify error handling
        XCTAssertEqual(loginViewModel.authState, .error("Unauthorized access"))
        XCTAssertFalse(loginViewModel.isAuthenticated)
        XCTAssertTrue(loginViewModel.accessToken.isEmpty)
    }
    
    // MARK: - Food Items Flow Integration Tests
    
    func testCompleteFoodItemsFlowSuccess() async throws {
        // Setup mock network service with successful response
        let mockData = """
        {
            "foodItems": [
                {
                    "id": 1,
                    "name": "Integration Pizza",
                    "description": "Delicious integration pizza",
                    "price": 15.99,
                    "imageUrl": "https://example.com/integration-pizza.jpg",
                    "category": "Integration"
                },
                {
                    "id": 2,
                    "name": "Integration Burger",
                    "description": "Delicious integration burger",
                    "price": 12.99,
                    "imageUrl": "https://example.com/integration-burger.jpg",
                    "category": "Integration"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/food-items")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        let mockSession = MockURLSession()
        mockSession.mockData = mockData
        mockSession.mockResponse = mockResponse
        
        // Create real services with mock network
        let networkService = NetworkService(session: mockSession)
        let foodService = FoodService(networkService: networkService)
        let foodViewModel = FoodViewModel(foodService: foodService)
        
        // Fetch food items
        await foodViewModel.fetchFoodItems(token: "integration-token")
        
        // Verify complete flow
        XCTAssertEqual(foodViewModel.foodState, .loaded([
            FoodItem(id: 1, name: "Integration Pizza", description: "Delicious integration pizza", price: 15.99, imageUrl: "https://example.com/integration-pizza.jpg", category: "Integration"),
            FoodItem(id: 2, name: "Integration Burger", description: "Delicious integration burger", price: 12.99, imageUrl: "https://example.com/integration-burger.jpg", category: "Integration")
        ]))
        XCTAssertEqual(foodViewModel.foodItems.count, 2)
        XCTAssertEqual(foodViewModel.foodItems[0].name, "Integration Pizza")
        XCTAssertEqual(foodViewModel.foodItems[1].name, "Integration Burger")
    }
    
    func testCompleteFoodItemsFlowWithServerError() async {
        // Setup mock network service with server error
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/food-items")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = mockResponse
        
        // Create real services with mock network
        let networkService = NetworkService(session: mockSession)
        let foodService = FoodService(networkService: networkService)
        let foodViewModel = FoodViewModel(foodService: foodService)
        
        // Fetch food items
        await foodViewModel.fetchFoodItems(token: "integration-token")
        
        // Verify error handling
        XCTAssertEqual(foodViewModel.foodState, .error("Server error with code: 500"))
        XCTAssertTrue(foodViewModel.foodItems.isEmpty)
    }
    
    func testCompleteFoodItemsFlowWithUnauthorizedError() async {
        // Setup mock network service with unauthorized error
        let mockResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/food-items")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = mockResponse
        
        // Create real services with mock network
        let networkService = NetworkService(session: mockSession)
        let foodService = FoodService(networkService: networkService)
        let foodViewModel = FoodViewModel(foodService: foodService)
        
        // Fetch food items with invalid token
        await foodViewModel.fetchFoodItems(token: "invalid-token")
        
        // Verify error handling
        XCTAssertEqual(foodViewModel.foodState, .error("Unauthorized access"))
        XCTAssertTrue(foodViewModel.foodItems.isEmpty)
    }
    
    // MARK: - End-to-End Flow Tests
    
    func testEndToEndLoginAndFoodItemsFlow() async throws {
        // Setup mock network service for login
        let loginData = """
        {
            "accessToken": "e2e-test-token",
            "refreshToken": "e2e-refresh-token"
        }
        """.data(using: .utf8)!
        
        let loginResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/login")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        // Setup mock network service for food items
        let foodData = """
        {
            "foodItems": [
                {
                    "id": 1,
                    "name": "E2E Pizza",
                    "description": "Delicious E2E pizza",
                    "price": 18.99,
                    "imageUrl": "https://example.com/e2e-pizza.jpg",
                    "category": "E2E"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let foodResponse = HTTPURLResponse(
            url: URL(string: "http://localhost:3000/food-items")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        // Create a mock session that returns different responses based on the request
        let mockSession = MockURLSessionWithMultipleResponses()
        mockSession.addResponse(for: "/login", data: loginData, response: loginResponse)
        mockSession.addResponse(for: "/food-items", data: foodData, response: foodResponse)
        
        // Create real services
        let networkService = NetworkService(session: mockSession)
        let authService = AuthService(networkService: networkService)
        let foodService = FoodService(networkService: networkService)
        
        // Create view models
        let loginViewModel = LoginViewModel(authService: authService)
        let foodViewModel = FoodViewModel(foodService: foodService)
        
        // Step 1: Login
        loginViewModel.username = "e2euser"
        loginViewModel.password = "e2epass"
        await loginViewModel.login()
        
        // Verify login success
        XCTAssertEqual(loginViewModel.authState, .authenticated)
        XCTAssertTrue(loginViewModel.isAuthenticated)
        XCTAssertEqual(loginViewModel.accessToken, "e2e-test-token")
        
        // Step 2: Fetch food items using the token from login
        await foodViewModel.fetchFoodItems(token: loginViewModel.accessToken)
        
        // Verify food items loaded
        XCTAssertEqual(foodViewModel.foodState, .loaded([
            FoodItem(id: 1, name: "E2E Pizza", description: "Delicious E2E pizza", price: 18.99, imageUrl: "https://example.com/e2e-pizza.jpg", category: "E2E")
        ]))
        XCTAssertEqual(foodViewModel.foodItems.count, 1)
        XCTAssertEqual(foodViewModel.foodItems[0].name, "E2E Pizza")
    }
}

// MARK: - Mock URLSession with Multiple Responses

//class MockURLSessionWithMultipleResponses: URLSession {
//    private var responses: [String: (Data, HTTPURLResponse)] = [:]
//    
//    func addResponse(for path: String, data: Data, response: HTTPURLResponse) {
//        responses[path] = (data, response)
//    }
//    
//    override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
//        guard let url = request.url,
//              let path = url.path.isEmpty ? "/" : url.path,
//              let (data, response) = responses[path] else {
//            throw NetworkError.unknown
//        }
//        
//        return (data, response)
//    }
//}
final class MockURLSessionWithMultipleResponses: URLSessionProtocol {
    private var responses: [String: (Data, HTTPURLResponse)] = [:]
    
    func addResponse(for path: String, data: Data, response: HTTPURLResponse) {
        responses[path] = (data, response)
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        guard let url = request.url else {
            throw NetworkError.unknown
        }
        
        // Normalize empty path to "/"
        let path = url.path.isEmpty ? "/" : url.path
        
        guard let (data, response) = responses[path] else {
            throw NetworkError.unknown
        }
        
        return (data, response)
    }
}
